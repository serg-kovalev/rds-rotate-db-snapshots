# rds-rotate-db-snapshots

[<img src="https://badge.fury.io/rb/rds-rotate-db-snapshots.svg" alt="Gem
Version" />](https://badge.fury.io/rb/rds-rotate-db-snapshots) [![CI](https://github.com/serg-kovalev/rds-rotate-db-snapshots/actions/workflows/ci.yml/badge.svg?query=branch%3Amain+event%3Apush)](https://github.com/serg-kovalev/rds-rotate-db-snapshots/actions/workflows/ci.yml?query=branch%3Amain+event%3Apush) [![CodeQL](https://github.com/serg-kovalev/rds-rotate-db-snapshots/actions/workflows/codeql.yml/badge.svg?query=branch%3Amain+event%3Apush)](https://github.com/serg-kovalev/rds-rotate-db-snapshots/actions/workflows/codeql.yml?query=branch%3Amain+event%3Apush)

Provides a simple way to rotate db snapshots in Amazon Relational Database
Service (RDS).

## Tested on Rubies

- 2.7
- 3.1
- 3.2

## Usage

Gem installation:

```bash
gem install rds-rotate-db-snapshots
```

Usage:

```bash
rds-rotate-db-snapshots [options] <db_indentifier>
```

Add this script to CRON (let's say it will run this script every X hours) and it will do the job well

```bash
#/usr/bin/bash
AWS_ACCESS_KEY='xxxxxxxxxxxxxxxxxxxx'
AWS_SECRET_ACCESS_KEY='yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy'
AWS_REGION='eu-west-1'
DESCRIPTION_PREFIX='automatic-backup-'
RDS_ROTATOR=/here/is/the/path/to/rds-rotate-db-snapshots
DB_NAME='db_name_here'

$RDS_ROTATOR --aws-region $AWS_REGION --aws-access-key $AWS_ACCESS_KEY --aws-secret-access-key $AWS_SECRET_ACCESS_KEY --pattern $DESCRIPTION_PREFIX --keep-hourly 24 --keep-daily 7 --keep-weekly 4 --keep-monthly 1 --keep-yearly 0 --create-snapshot $DESCRIPTION_PREFIX$DB_NAME $DB_NAME
```

## Options

- `--aws-access-key ACCESS_KEY` "AWS Access Key"
- `--aws-secret-access-key SECRET_KEY` "AWS Secret Access Key"
- `--aws-region REGION` "AWS Region"
- `--pattern STRING` "Snapshots without this string in the description will be ignored"
- `--by-tags TAG=VALUE,TAG=VALUE` "Instead of rotating specific snapshots, rotate over all the snapshots having the intersection of all given TAG=VALUE pairs."
- `--backoff-limit INTEGER` "Backoff and retry when hitting RDS Error exceptions no more than this many times. Default is 15"
- `--create-snapshot STRING` "Use this option if you want to create a snapshot"
- `--keep-hourly INTEGER` "Number of hourly snapshots to keep"
- `--keep-daily INTEGER` "Number of daily snapshots to keep"
- `--keep-weekly INTEGER` "Number of weekly snapshots to keep"
- `--keep-last` "Keep the most recent snapshot, regardless of time-based policy"
- `--dry-run` "Shows what would happen without doing anything"

## Tips

If you are not sure what happen - add option `--dry-run`.

In that case the script will not destroy/create anything in RDS, it will just
show the messages.

## Contributing to rds-rotate-db-snapshots

- Check out the latest main to make sure the feature hasn't been
  implemented or the bug hasn't been fixed yet
- Check out the issue tracker to make sure someone already hasn't requested
  it and/or contributed it
- Fork the project
- Start a feature/bugfix branch
- Commit and push until you are happy with your contribution
- Make sure to add tests for it. This is important so I don't break it in a
  future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want
  to have your own version, or is otherwise necessary, that is fine, but
  please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2014 Siarhei Kavaliou. See LICENSE.txt for further details.
