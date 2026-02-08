# Backend Architecture Document - Updated

## What The Fed - Backend Architecture

---

## 1. Backend Role in the System

### 1.1 Purpose
The backend is the source of truth for all civic data and analysis. It is responsible for:
- Persisting primary-source government data
- Exposing stable, typed APIs to clients
- Coordinating AI analysis workflows
- Preserving transparency, provenance, and versioning

The backend does not editorialize. Interpretation lives in analysis layers, not core storage.

---

## 2. Technology Stack

### 2.1 Core Technologies
- **Serverpod (Dart)**
  - API layer
  - ORM & migrations
  - Background tasks
- **PostgreSQL**
  - Primary data store
  - pgvector extension for embeddings
- **Python ingestion scrapers**
  - Scrape raw data and store structured data on disk for Serverpod ingestion scripts to access
- **Docker**
  - Local dev & deployment parity

### 2.2 Why Serverpod
- Shared types with Flutter client
- Strongly typed API contracts
- Integrated database tooling
- Clean separation of concerns (endpoints, services, jobs)

---

## 3. High-Level Backend Architecture

### 3.1 Logical Layers
- **Ingestion layer**
  - Accepts external data (Python scrapers)
- **Domain layer**
  - Bills, votes, people, committees, subjects
- **Analysis coordination layer**
  - Triggers and stores AI outputs
- **API layer**
  - Read-optimized endpoints for clients
- **Background jobs**
  - Long-running or async work implemented using Serverpod future calls

### 3.2 Design Principles
- Idempotent ingestion
- Immutable primary sources
- Explicit relationships
- Read-heavy optimization
- No silent data mutation

---

## 4. Data Model & Schema Design

### 4.1 Domain Organization

The database schema is organized into four primary domains, each in its own directory:

```
lib/src/models/
├── politician/           # Politician, Term, LeadershipRole, TermType
├── legislation/          # Bill, Vote, Subject, BillAction, BillCosponsor, 
│                        # BillSubject, BillVersion, BillVersionChunk, VoteResult
├── congressional_record/ # CongressionalRecord, CongressionalRecordPart, 
│                        # ContentItem, ContentType
└── document/            # DocumentChunk, DocumentType
```

### 4.2 Core Domain Entities

#### A. Politician Domain

**Politician** - Core entity representing members of Congress and executive branch
- **External Identifiers** (19 fields): `bioguideId`, `govtrackId`, `thomasId`, `lisId`, `fecIds`, `opensecretsId`, `voteSmartId`, `icpsrId`, `cspanId`, `wikipediaId`, `ballotpediaId`, `maplightId`, `houseHistoryId`, `bioguidePreviousId`, `pictorialId`
- **Biographical Data**: `firstName`, `middleName`, `lastName`, `suffix`, `nickname`, `officialName`, `birthday`, `gender`
- **Social Media**: `twitter`, `youtube`, `instagram`, `facebook`, `mastodon`
- **Denormalized Current Status** (for performance): `lastTermEnd`, `isCurrent`, `lastType`, `lastParty`, `lastState`, `lastDistrict`
- **Denormalized Leadership**: `hasLeadershipRole`, `currentLeadershipTitle`, `currentLeadershipChamber`
- **Relations**: `terms`, `leadershipRoles`, `sponsoredBills`, `cosponsoredBills`, `speeches`
- **Indexes**: 
  - `politician_bioguide_idx` (bioguideId)
  - `politician_govtrack_idx` (govtrackId, unique)
  - `politician_is_current_idx` (isCurrent)
  - `politician_party_idx` (lastParty)
  - `politician_state_idx` (lastState)

**Term** - Represents a single term of service
- **Fields**: `type` (TermType), `start`, `end`, `state`, `district`, `electionClass`, `stateRank`, `party`, `caucus`
- **Contact Metadata**: `url`, `address`, `phone`, `contactForm`, `office`, `rssUrl`
- **Indexes**: `term_begin_idx`, `term_end_idx`, `term_state_idx`

**LeadershipRole** - Leadership positions held
- **Fields**: `title`, `chamber`, `start`, `end`
- No explicit indexes beyond foreign key

**TermType** - Enum
- Values: `rep`, `sen`, `prez`, `viceprez`

#### B. Legislation Domain

**Bill** - Core legislative entity
- **Identifiers**: `congress`, `type` (BillType), `number`
- **Core Metadata**: `title`, `popularTitle`, `shortTitle`, `introducedDate`, `updatedDate`, `status`, `statusDate`
- **High-Value Search Target**: `summary` (CRS Summary text)
- **Relations**: `sponsor` (Politician), `subjects`, `actions`, `cosponsors`, `votes`, `versions`
- **Indexes**:
  - `bill_lookup_idx` (congress, type, number, unique)
  - `bill_sponsor_idx` (sponsorId)
  - `bill_congress_idx` (congress)
  - `bill_status_idx` (status)

**BillType** - Enum
- Values: `hr`, `s`, `hjres`, `sjres`, `hconres`, `sconres`, `hres`, `sres`

**BillAction** - Legislative actions taken on a bill
- **Fields**: `actedAt`, `type`, `text`, `chamber`

**BillSubject** - Join table linking bills to subjects
- **Fields**: `bill`, `subject`
- **Indexes**: `bill_subject_idx` (billId, subjectId, unique)

**Subject** - Subject taxonomy
- **Fields**: `name`, `bills` (relation)
- **Indexes**: `subject_name_idx`

**BillCosponsor** - Join table for bill cosponsorship
- **Fields**: `bill`, `politician`, `sponsoredDate`, `withdrawnDate`
- **Indexes**: `bill_cosponsor_idx` (billId, politicianId, sponsoredDate, unique)

**BillVersion** - Different versions of bill text
- **Fields**: `versionCode` (e.g., "ih", "enr"), `date`, `path` (file path on disk), `chunks` (relation)

**BillVersionChunk** - Join table linking bill versions to document chunks
- **Fields**: `billVersion`, `documentChunk`
- **Indexes**: 
  - `bill_version_chunk_bill_version_idx`
  - `bill_version_chunk_document_chunk_idx`
  - `bill_version_chunk_combined_idx` (documentChunkId, billVersionId)

#### C. Voting Domain

**Vote** - Congressional votes
- **Identifiers**: `chamber`, `congress`, `number`, `session`, `voteId`
- **Metadata**: `date`, `sourceUrl`, `updatedAt`
- **Vote Details**: `category`, `question`, `type`, `requires`, `result`, `resultText`
- **Relations**: `bill` (optional), `results`
- **Indexes**:
  - `vote_id_idx` (voteId, unique)
  - `vote_bill_idx` (billId)
  - `vote_congress_idx` (congress)
  - `vote_chamber_idx` (chamber)

**VoteResult** - Join table for individual politician votes
- **Fields**: `vote`, `politician`, `voteType` (Yea/Nay/Present/Not Voting)
- **Indexes**: `vote_result_vote_idx`, `vote_result_politician_idx`

#### D. Congressional Record Domain

**CongressionalRecord** - Daily Congressional Record publication
- **Fields**: `date`, `volume`, `issue`
- **Relations**: `senateParts`, `houseParts`
- **Indexes**: `date_idx`, `volume_issue_idx`
- **Note**: Congressional Records are immutable once ingested

**CongressionalRecordPart** - Individual sections within a record
- **Fields**: `date` (denormalized), `chamber`, `beginPage`, `endPage`, `title`, `isExtension`
- **Relations**: `content` (list of ContentItems)
- **Indexes**:
  - `chamber_idx`
  - `record_part_date_idx`
  - `unique_part_idx` (date, chamber, beginPage, endPage, unique)

**ContentItem** - Individual content items (speeches, procedural text)
- **Fields**: 
  - `date` (denormalized for efficient filtering)
  - `chamber` (denormalized)
  - `type` (ContentType)
  - `speaker`
  - `speakerBioguide`
  - `speakerPolitician` (relation, optional)
  - `text`
  - `turn`
  - `itemNumber`
- **Relations**: `chunks` (DocumentChunks)
- **Indexes**:
  - `type_idx`
  - `speaker_politician_idx`
  - `content_item_date_idx`
  - `speaker_date_composite_idx` (speakerPoliticianId, date)
  - `chamber_speaker_date_idx` (chamber, speakerPoliticianId, date)

**ContentType** - Enum
- Values: `speech`, `recorder`, `clerk`, `linebreak`, `excerpt`, `rollcall`, `metacharacters`, `empty_line`, `title`, `Unknown`

#### E. Document/Embedding Domain

**DocumentChunk** - Text chunks for semantic search
- **Fields**: 
  - `documentType` (DocumentType)
  - `hash` (SHA256 of content)
  - `content` (text)
  - `embedding` (Vector(768) - 768-dimensional embedding)
- **Indexes**:
  - `document_chunk_hash_idx` (hash, unique)
  - `document_chunk_embedding_idx` (HNSW index with cosine distance, m=16, ef_construction=64)
  - `document_chunk_type_idx` (documentType)

**DocumentType** - Enum
- Values: `bill`, `congressional_record`

### 4.3 Join Tables & Normalization

All many-to-many relationships use explicit join tables:

| Join Table | Left Entity | Right Entity | Additional Fields |
|------------|-------------|--------------|-------------------|
| BillSubject | Bill | Subject | - |
| BillCosponsor | Bill | Politician | sponsoredDate, withdrawnDate |
| VoteResult | Vote | Politician | voteType |
| BillVersionChunk | BillVersion | DocumentChunk | - |

**Benefits of explicit join tables:**
- Enables indexing on relationship attributes
- Prevents data duplication
- Supports future metadata (e.g., relevance scores)
- Makes relationship queries more efficient

### 4.4 Denormalization Strategy

Strategic denormalization is used for performance:

| Entity | Denormalized Fields | Reason |
|--------|---------------------|--------|
| Politician | lastTermEnd, isCurrent, lastType, lastParty, lastState, lastDistrict | Avoid joins when filtering current members |
| Politician | hasLeadershipRole, currentLeadershipTitle, currentLeadershipChamber | Fast leadership queries |
| ContentItem | date, chamber | Efficient filtering without joining to CongressionalRecord |
| CongressionalRecordPart | date | Fast date-based queries |

### 4.5 Provenance & Metadata

Every primary entity stores:
- **Source system identifiers**: External IDs (e.g., bioguideId, voteId)
- **Ingestion timestamp**: `updatedAt` fields
- **Data version**: Implicit through `updatedAt`
- **Source URLs**: Where applicable (e.g., Vote.sourceUrl)

**Immutability rules:**
- Congressional Records are never updated once ingested
- Bills and Politicians use upsert logic on external IDs
- Votes are identified by unique voteId

### 4.6 Entity Relationship Overview

```
Politician (1) ──────< (M) Term
    │
    ├──────< (M) LeadershipRole
    │
    ├──────< (M) Bill (as sponsor)
    │
    ├──────< (M) BillCosponsor ──────> (1) Bill
    │
    ├──────< (M) VoteResult ──────> (1) Vote
    │
    └──────< (M) ContentItem (as speaker)

Bill (1) ──────< (M) BillAction
    │
    ├──────< (M) BillSubject ──────> (1) Subject
    │
    ├──────< (M) BillVersion ──────< (M) BillVersionChunk ──────> (1) DocumentChunk
    │
    └──────< (M) Vote

CongressionalRecord (1) ──────< (M) CongressionalRecordPart
    │
    └──────< (M) ContentItem ──────< (M) DocumentChunk

DocumentChunk (used by multiple entities via join tables)
```

---

## 5. Ingestion Pipeline

### 5.1 Ingestion Strategy

- Python scrapers store data on disk for backend to access
- Backend never scrapes external sources directly
- Backend validates and persists only

**Data Flow:**
```
Python Scrapers → Disk Storage → Serverpod Importers → PostgreSQL
```

### 5.2 Ingestion Modules

The backend implements four main import modules with strict dependencies:

| Module | Source Data | Dependencies | Status |
|--------|-------------|--------------|--------|
| `ImportPoliticians` | `/home/ubuntu/scrapers/congress/congress-legislators` (YAML) | None | ✅ Implemented |
| `ImportBills` | `/home/ubuntu/scrapers/congress/data/{congress}/bills` (JSON) | Politicians | ✅ Implemented |
| `ImportVotes` | `/home/ubuntu/scrapers/congress/data/{congress}/votes` (JSON) | Politicians, Bills | ✅ Implemented |
| `ImportCongressionalRecords` | `/home/ubuntu/scrapers/congressional-record/output` (JSON) | Politicians | ✅ Implemented |

**Execution Order:** Politicians → Bills → Votes → Congressional Records

### 5.3 Ingestion Architecture Pattern

All importers follow a consistent pattern:

```dart
class ImportXXX {
  static String dataPath = '/path/to/data';
  
  static Future<void> import(Session session) async {
    final stats = ImportStats<XXXErrorType>();
    // Process files
    // Record statistics
    stats.logSummary(session, 'EntityName');
  }
}
```

**Key components:**
- **Typed error tracking**: Each importer defines an error enum
- **Import statistics**: Tracks inserted, updated, unchanged, and error counts
- **Transaction boundaries**: Per-file or per-entity transactions for atomicity
- **Logging**: Structured logging via Session extensions
- **Error recovery**: Partial failures don't abort entire import

### 5.4 Error Handling Strategy

Each importer defines typed error enums:

**PoliticianErrorType:**
```dart
enum PoliticianErrorType {
  missingGovtrackId,
  missingTerms,
  format,
  database,
  other,
}
```

**BillErrorType:**
```dart
enum BillErrorType {
  missingSponsor,
  missingCosponsor,
  format,
  other
}
```

**VoteErrorType:**
```dart
enum VoteErrorType {
  missingPolitician,
  missingBill,
  format,
  other
}
```

**CongressionalRecordErrorType:**
```dart
enum CongressionalRecordErrorType {
  missingDate,
  missingSession,
  missingVolume,
  missingPage,
  missingContent,
  missingSpeaker,
  missingBill,
  format,
  other,
}
```

**Error tracking features:**
- Error count by type
- First 5 error details logged
- Context preservation (e.g., govtrackId, billId)
- Custom exceptions for domain-specific errors

### 5.5 Idempotency & Upsert Logic

Key rules:
- **Ingestion must be idempotent**: Re-running the same data should not corrupt state
- **Upsert on natural keys**: Bills by (congress, type, number), Politicians by govtrackId, Votes by voteId
- **Immutable records**: Congressional Records are never updated if they exist
- **Soft validation**: Bad records are rejected explicitly, logged, and tracked in statistics

### 5.6 Example: Bill Ingestion Flow

```
1. Read JSON file: {congress}/bills/{type}/{number}/data.json
2. Start transaction
3. Lookup sponsor by bioguideId → Politician ID
4. Lookup/create Bill (upsert by congress+type+number)
5. For each cosponsor:
   - Lookup politician by bioguideId
   - Create/update BillCosponsor record
6. For each subject:
   - Lookup/create Subject by name
   - Create BillSubject link
7. For each action:
   - Create BillAction record
8. Commit transaction
9. Record stats (inserted/updated/unchanged/error)
```

**Error scenarios:**
- Missing sponsor → Skip bill, log `missingSponsor` error
- Missing cosponsor → Skip cosponsor, log `missingCosponsor` error
- Invalid JSON → Skip file, log `format` error

### 5.7 Ingestion Orchestration

The **ScraperOrchestratorFutureCall** coordinates the entire pipeline:

```dart
class ScraperOrchestratorFutureCall extends FutureCall {
  static const identifier = 'scraper-orchestrator';
  
  Future<void> orchestrate(Session session, SerializableModel? object) async {
    // 1. Run Python scrapers via shell script
    await _runScraperScript(session);
    
    // 2. Run importers in sequence
    await ImportPoliticians.import(session);
    await ImportBills.import(session);
    await ImportVotes.import(session);
    await ImportCongressionalRecords.import(session);
    
    // 3. Reschedule for 12 hours from now
    await _rescheduleNextRun(session);
  }
}
```

**Features:**
- Executes external scraper script: `/home/ubuntu/scrapers/scrape.sh`
- Self-rescheduling pattern (12-hour interval)
- Error handling with stack trace logging
- Runs as a Serverpod FutureCall

---

## 6. API Design

### 6.1 API Implementation Status

**Current state:** The endpoint dispatch system is configured but no public endpoints have been implemented yet.

```dart
class Endpoints extends EndpointDispatch {
  @override
  void initializeEndpoints(Server server) {
    // Empty - no endpoints registered yet
  }
}
```

### 6.2 Planned API Types

**Public read APIs** (require login, not yet implemented):
- Bills API
- Votes API
- Politicians API
- Congressional Records API
- Subjects API
- AI chat API

**Internal APIs** (planned):
- Ingestion triggers
- Analysis job triggers
- Admin utilities

### 6.3 API Design Principles

- **Deterministic responses**: Same input always produces same output
- **Pagination everywhere**: All list endpoints will support pagination
- **Stable contracts**: Breaking changes require new API versions
- **Explicit filtering**: No "magic" behavior or implicit filters

### 6.4 Client Compatibility

- APIs are Flutter-first
- Generated Serverpod client is the canonical interface
- No "hidden" response fields
- Shared type definitions between client and server

### 6.5 Planned Endpoint Categories

#### Politicians Endpoints (planned)
```
GET /politicians?party={party}&state={state}&isCurrent={bool}
GET /politicians/{id}
GET /politicians/{id}/bills
GET /politicians/{id}/votes
GET /politicians/{id}/speeches
```

#### Bills Endpoints (planned)
```
GET /bills?congress={num}&status={status}
GET /bills/{congress}/{type}/{number}
GET /bills/{id}/votes
GET /bills/{id}/actions
GET /bills/{id}/versions
```

#### Votes Endpoints (planned)
```
GET /votes?congress={num}&chamber={chamber}
GET /votes/{id}
GET /votes/{id}/results
```

#### Congressional Records Endpoints (planned)
```
GET /congressional-records?date={date}
GET /congressional-records/{id}
GET /congressional-records/{id}/parts
GET /content-items?speaker={politicianId}&date={date}
```

#### Semantic Search Endpoint (planned)
```
POST /search/semantic
Body: { query: string, documentType?: string, limit?: int }
Returns: List<DocumentChunk> with similarity scores
```

---

## 7. AI Agent Coordination

### 7.1 Backend Role in AI

The backend:
- Triggers AI agents for analysis
- Provides tools for AI agents to access backend information
- Stores structured outputs
- Links analysis to source data

All AI Agent coordination uses the **Dartantic library** and **Openrouter** to consolidate all AI APIs.

### 7.2 AI Agent Types

**Chat agent**
- Responds to questions from the user
- Uses tool calls to access backend data
- Returns grounded answers with citations

**Research agent**
- Researches relevant data in database
- Synthesizes findings to answer questions
- Produces structured research outputs

**Debate agent**
- Creates arguments on issues based on political viewpoints
- Debates issues over multiple rounds with other agents
- References legislative data to support positions

### 7.3 Analysis Storage & Versioning

Each analysis:
- **Is versioned**: Track which model/prompt version generated it
- **Is reproducible**: Store inputs and parameters
- **References exact source inputs**: Link to specific bills, votes, speeches

**Note:** Implementation details for AI analysis storage are not yet reflected in the database schema. This is a planned feature.

### 7.4 AI-Backend Integration Points (Planned)

- **Tool Functions**: Backend endpoints callable by AI agents
- **Context Retrieval**: Semantic search over DocumentChunks
- **Data Grounding**: Link AI outputs to source entities (Bill, Vote, etc.)
- **Provenance Tracking**: Record which data influenced which analysis

---

## 8. Background Jobs & Async Work

### 8.1 FutureCall System

Serverpod's FutureCall system enables asynchronous, scheduled, and recurring jobs.

**Key features:**
- Restart-safe execution
- Delayed execution
- Recurring schedules
- Identifier-based deduplication

### 8.2 When Jobs Are Used

- Long-running ingestion (12+ hour scraping + import cycles)
- AI analysis orchestration (planned)
- Periodic data refreshes
- Scheduled report generation (planned)

### 8.3 Implemented: ScraperOrchestratorFutureCall

**Purpose:** Orchestrate the entire data ingestion pipeline

**Pattern:**
```dart
class ScraperOrchestratorFutureCall extends FutureCall {
  static const identifier = 'scraper-orchestrator';
  static String scraperScriptPath = IngestionConfig.scraperScriptPath;

  Future<void> orchestrate(Session session, SerializableModel? object) async {
    // 1. Execute external Python scrapers
    if (await _runScraperScript(session)) {
      // 2. Import data in sequence
      await ImportPoliticians.import(session);
      await ImportBills.import(session);
      await ImportVotes.import(session);
      await ImportCongressionalRecords.import(session);
    }
    
    // 3. Self-reschedule for 12 hours
    await _rescheduleNextRun(session);
  }
}
```

**Scheduling:**
```dart
await Serverpod.instance.futureCalls
    .callWithDelay(Duration(hours: 12), identifier: identifier)
    .scraperOrchestrator
    .orchestrate(null);
```

**Features:**
- Executes shell script: `/home/ubuntu/scrapers/scrape.sh`
- Captures stdout/stderr from scraper
- Logs all errors with stack traces
- Automatic rescheduling ensures continuous updates
- Identifier prevents duplicate runs

### 8.4 Job Design Rules

- **Jobs are restart-safe**: Can be interrupted and resumed
- **Progress is checkpointed**: Importers track per-file/entity progress
- **Failures are visible**: All errors logged with context
- **Idempotent operations**: Re-running jobs doesn't corrupt data

### 8.5 Future Job Types (Planned)

- **AI Analysis Jobs**: Trigger analysis on new bills/votes
- **Embedding Generation**: Generate embeddings for new content
- **Report Generation**: Periodic summaries and alerts
- **Data Cleanup**: Archive old data, vacuum embeddings

---

## 9. Security & Access Control

### 9.1 Authentication

**Current implementation status:** Not yet implemented

**Planned:**
- Read access for logged-in users
- Restricted access for:
  - Ingestion endpoints
  - Admin operations
  - Future call triggers

### 9.2 Data Integrity

- **No client can mutate primary-source records**: All ingestion is server-controlled
- **Soft deletes preferred over hard deletes**: Preserve historical data
- **Audit trails planned**: Track who accessed what data

### 9.3 API Security (Planned)

- JWT-based authentication
- Rate limiting per user/endpoint
- Request logging for audit
- CORS configuration for web clients

---

## 10. Deployment Strategy & Environments

### 10.1 Environments

- **Local**: Docker Compose for development
- **Staging**: AWS deployment for testing
- **Production**: AWS deployment with managed services

### 10.2 Deployment Model

**Dockerized Serverpod service:**
```dockerfile
FROM dart:3.8 AS build
WORKDIR /app
COPY . .
RUN dart pub get
RUN dart compile exe bin/main.dart -o bin/server

FROM alpine:latest
ENV runmode=production
ENV serverid=default
COPY --from=build /app/bin/server server
COPY --from=build /app/config/ config/
COPY --from=build /app/migrations/ migrations/
EXPOSE 8080 8081 8082
ENTRYPOINT ["./server"]
```

**Components:**
- Managed PostgreSQL (AWS RDS)
- Serverpod server (ECS or EC2)
- Background workers (same container, scaled independently if needed)

### 10.3 Infrastructure (AWS)

**Based on deployment scripts:**
- **Compute**: EC2 instances running Dart SDK 3.5.1
- **Database**: PostgreSQL with pgvector extension
- **Storage**: EBS volumes for scraper data
- **Deployment**: CodeDeploy with install_dependencies, start_server scripts

**File paths on server:**
- Dart SDK: `/usr/lib/dart3.5.1`
- Scraper data: `/home/ubuntu/scrapers/`
- Working directory: `/home/ec2-user`

---

## 11. Database Indexes & Performance

### 11.1 Indexing Strategy

**Unique indexes for natural keys:**
- `bill_lookup_idx` (congress, type, number)
- `vote_id_idx` (voteId)
- `politician_govtrack_idx` (govtrackId)
- `document_chunk_hash_idx` (hash)

**Composite indexes for filtering:**
- `speaker_date_composite_idx` (speakerPoliticianId, date)
- `chamber_speaker_date_idx` (chamber, speakerPoliticianId, date)
- `vote_congress_idx` (congress)

**Vector similarity search:**
- HNSW index on `document_chunk.embedding`
- Cosine distance function
- Parameters: m=16, ef_construction=64
- Enables fast semantic search across 768-dimensional embeddings

### 11.2 Denormalization for Performance

Strategic denormalization avoids expensive joins:

| Denormalized Field | Entity | Purpose |
|-------------------|--------|---------|
| isCurrent | Politician | Filter current members without term join |
| lastParty, lastState | Politician | Filter by current affiliation |
| hasLeadershipRole | Politician | Quick leadership filtering |
| date, chamber | ContentItem | Filter speeches without joining CongressionalRecord |

### 11.3 Query Optimization Patterns

- **Pagination**: All list queries will use LIMIT/OFFSET
- **Covering indexes**: Include frequently-queried columns in indexes
- **Foreign key indexes**: Automatic on all relations
- **Partial indexes**: Planned for `isCurrent=true` queries

---

## 12. Migration Strategy

### 12.1 Serverpod Migrations

- Migrations auto-generated via `serverpod generate`
- Stored in `/migrations/` directory
- Applied automatically on server startup
- Version tracked in `serverpod_migrations` table

### 12.2 Migration History

Current migration version: `20260201161413125`

**Migration pattern:**
```sql
BEGIN;
-- DDL statements
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('lucent', '20260201161413125', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260201161413125';
COMMIT;
```

### 12.3 Schema Evolution Rules

- Never drop columns (add nullable columns instead)
- Use migrations for schema changes (not manual SQL)
- Test migrations in staging before production
- Keep old data during transitions

---

## 13. Monitoring & Observability (Planned)

### 13.1 Logging

**Current implementation:**
- Session-based logging via `SessionLogging` extension
- Log levels: info, warning, error
- Structured log output to stdout

**Planned:**
- Centralized log aggregation (CloudWatch)
- Request/response logging for all endpoints
- Performance metrics per endpoint

### 13.2 Metrics (Planned)

- Ingestion job duration and success rate
- API endpoint latency (p50, p95, p99)
- Database connection pool utilization
- Error rates by type

### 13.3 Health Checks (Built-in)

Serverpod provides built-in health monitoring:
- `serverpod_health_connection_info` table
- Connection metrics: active, closing, idle
- Granularity-based time-series data

---

## Appendix A: Model Reference

### Complete Model List (25 models)

| Model | Table | Type | Domain |
|-------|-------|------|--------|
| Politician | politician | class | politician |
| Term | term | class | politician |
| LeadershipRole | leadership_role | class | politician |
| TermType | - | enum | politician |
| Bill | bill | class | legislation |
| BillAction | bill_action | class | legislation |
| BillType | - | enum | legislation |
| BillSubject | bill_subject | class | legislation |
| BillCosponsor | bill_cosponsor | class | legislation |
| BillVersion | bill_version | class | legislation |
| BillVersionChunk | bill_version_chunk | class | legislation |
| Subject | subject | class | legislation |
| Vote | vote | class | legislation |
| VoteResult | vote_result | class | legislation |
| CongressionalRecord | congressional_record | class | congressional_record |
| CongressionalRecordPart | congressional_record_part | class | congressional_record |
| ContentItem | content_item | class | congressional_record |
| ContentType | - | enum | congressional_record |
| DocumentChunk | document_chunk | class | document |
| DocumentType | - | enum | document |

---

## Appendix B: Future Enhancements

### Planned Features

1. **Public API Endpoints**: Full REST API for client applications
2. **AI Analysis Storage**: Tables for storing AI-generated insights
3. **Authentication System**: JWT-based user authentication
4. **Committee Tracking**: Committee membership and hearing data
5. **Amendment Tracking**: Bill amendments as separate entities
6. **Full-Text Search**: PostgreSQL full-text search on bill text
7. **Real-Time Subscriptions**: WebSocket support for live updates
8. **Admin Dashboard**: Management interface for data quality
9. **Data Export API**: Bulk export for researchers
10. **GraphQL Layer**: Alternative to REST for complex queries

### Research Questions

- How should we store AI agent conversations and tool calls?
- Should we implement a separate microservice for AI orchestration?
- How do we version AI model outputs when models change?
- What's the best approach for handling streaming AI responses?

---

## Appendix C: Key Files Reference

```
lucent_server/
├── lib/src/
│   ├── models/                    # Serverpod model definitions (.spy.yaml)
│   │   ├── politician/
│   │   ├── legislation/
│   │   ├── congressional_record/
│   │   └── document/
│   ├── ingestion/                 # Data import modules
│   │   ├── import_politicians.dart
│   │   ├── import_bills.dart
│   │   ├── import_votes.dart
│   │   ├── import_congressional_records.dart
│   │   ├── scraper_orchestrator.dart
│   │   └── utils.dart            # ImportStats, logging helpers
│   ├── endpoints/                 # API endpoints (empty currently)
│   └── generated/                 # Auto-generated code
│       ├── protocol.dart          # All model definitions
│       ├── endpoints.dart         # Endpoint dispatch
│       └── future_calls.dart      # Background job registry
├── migrations/                    # Database migrations
├── config/                        # Server configuration
├── Dockerfile                     # Container definition
└── bin/main.dart                  # Server entry point
```

---

**Document Version:** 2.0  
**Last Updated:** 2025-02-08  
**Status:** Living document - will be updated as implementation progresses
