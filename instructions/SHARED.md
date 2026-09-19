<shared_rules>
1. Read the target file in full before editing it. For a file over 500 lines, read the relevant section in full, then read the surrounding context before the first edit. Rationale: editing an unread region breaks invariants you cannot see.
2. Remove dead code, logs, and commented-out blocks in the files you touch; this cleanup is an explicit exception to <scope> rule 2.
</shared_rules>