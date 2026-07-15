# Frontend and Backend Schema Migration Deep Notes

## Why This Topic Matters
- Frontend teams often think in terms of forms, DTOs, and view models.
- Backend teams think in terms of database schema, entities, and migrations.
- Real production systems break when those evolve out of sync.

## What "Schema Sync" Really Means
- It does not mean the frontend talks directly to the database schema.
- It means the user-facing data model, API contract, validation rules, and persisted storage evolve in a coordinated way.

## Layers to Keep Aligned
- frontend form model
- frontend validation
- API request and response contract
- backend DTOs
- backend domain model
- database schema
- migration scripts

## Example Change

Old model:

```json
{
  "fullName": "Alice",
  "email": "a@example.com"
}
```

New requirement:
- split `fullName` into `firstName` and `lastName`

This affects:
- frontend form fields
- validation logic
- API contract
- backend DTO mapping
- DB schema migration
- data backfill for existing rows

## Safe Migration Strategy

### Risky Approach
1. change frontend payload
2. change DB schema
3. deploy everything at once

Problem:
- breaks rolling deployments
- old clients may fail
- partial release creates incompatibility

### Better Expand-and-Contract Strategy
1. add new DB columns
2. update backend to support both old and new contract temporarily
3. deploy frontend using new fields
4. backfill old records
5. remove deprecated field later

## Migration Tools
- Flyway
- Liquibase
- Alembic
- Prisma migrations
- Sequelize migrations

The tool matters less than the discipline:
- migrations must be versioned
- reviewed
- repeatable
- safe for rollback or forward-fix

## Example SQL Migration

```sql
alter table customer add column first_name varchar(100);
alter table customer add column last_name varchar(100);
```

Backfill:

```sql
update customer
set first_name = split_part(full_name, ' ', 1),
    last_name = substring(full_name from position(' ' in full_name) + 1)
where full_name is not null;
```

## Frontend Contract Evolution
- avoid tightly coupling UI state directly to DB structure
- use API contracts as the stable boundary
- map backend responses into frontend view models if needed

Example TypeScript:

```ts
type CustomerResponse = {
  firstName: string;
  lastName: string;
  email: string;
};

type CustomerViewModel = {
  displayName: string;
  email: string;
};

function toViewModel(data: CustomerResponse): CustomerViewModel {
  return {
    displayName: `${data.firstName} ${data.lastName}`,
    email: data.email
  };
}
```

## Versioning and Backward Compatibility
- old frontend may still call new backend
- new frontend may reach old backend during rollout
- API should handle transitional compatibility if zero-downtime deployment matters

## Common Interview Questions

### What happens if backend schema changes before frontend deploy?
Short answer:
If the change is breaking, old frontend clients may fail.

Better answer:
That is why I prefer additive, backward-compatible changes first. I expand the schema, keep old and new contract support during rollout, and only remove deprecated fields after consumers are fully migrated.

### Why not expose database schema directly to frontend?
Short answer:
Because UI and storage concerns evolve differently.

Better answer:
The frontend should depend on an API contract, not raw database structure. That keeps storage refactoring, normalization changes, and persistence decisions from leaking into the UI layer and making the system harder to evolve safely.

## Good Practices
- treat API schema as the formal integration boundary
- use typed frontend models
- add migration runbooks for risky data changes
- backfill data carefully
- monitor errors after deploy
- prefer additive changes before destructive ones
