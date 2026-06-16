# Semantic top-down modeling addendum — aggregated workflows

This addendum supersedes the aggregated-workflow guidance in `docs/semantic-top-down-modeling.md` where it describes aggregates as review-level behavior-domain slices.

Use `docs/design-notes/0013-aggregated-workflows-as-scenario-branches.md` as the current design position.

## Updated phase 11 guidance

Aggregated workflows are normal workflows that compose existing workflows with `workflow` + `bind` steps.

Because they are workflows, they must describe one behaviorally meaningful scenario branch.

They should answer:

```text
Which existing workflows compose this concrete scenario branch?
```

They should not answer:

```text
Which existing workflows must be reviewed together to understand this behavior boundary?
```

Good aggregated workflows are composed scenario branches, not broad review slices.

They must not include success, optional, failure, and terminal child workflows in the same aggregate unless those child workflows genuinely occur in the same concrete branch.

Their order should express scenario continuity, not review order.

Do not create aggregated workflows merely because workflows live in the same directory, share the same primary role, belong to the same semantic area, have similar names, or would make a convenient diagram page.

## Updated candidate gate

Create an aggregated workflow only when all of these are true:

- it names one concrete scenario branch;
- it composes existing workflows without adding behavior;
- every child workflow belongs to the same branch;
- child workflow order expresses scenario continuity;
- it is not merely a semantic-area, directory, role, naming, or lifecycle-coverage bucket;
- child workflow roles can be explicitly bound;
- the aggregate remains understandable without `main`, `variants`, `cases`, `outcome`, guards, branches, or execution control flow.

Do not create an aggregated workflow if it is just all workflows in a semantic area, all workflows for a role, a broad system bucket, a lifecycle coverage view, a collection of alternative branches, or something that would need `main`, `variants`, `cases`, or `outcome` to be understandable.

Record rejected and deferred aggregate candidates in a report rather than forcing them into the model.

## Updated anti-patterns

Avoid these patterns:

- aggregated workflows created as broad semantic buckets;
- aggregated workflows created as role buckets;
- aggregated workflows created as lifecycle coverage summaries;
- aggregated workflows created as review-order diagram pages;
- aggregated workflows that mix mutually exclusive branches;
- aggregated workflows that combine optional variants into one apparent sequence;
- aggregated workflows placed under technical `aggregated/`, `review/`, or `composite/` directories.

## Expected outcome

A semantic top-down BehavioML model should make it clear which aggregated workflows compose concrete scenario branches and which aggregate candidates were rejected because they were review slices, lifecycle coverage views, role buckets, or branch bundles.
