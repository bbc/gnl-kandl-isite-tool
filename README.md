K&L iSite2 XML Data Migrator
============================

## Background

When the development team update forms in iSite2 this can have an impact on the
XML associated with that form.

Any data created using that form, prior to the change, will not contain the
recent changes. This can lead to a number of issues such as
- Forms not displaying all the data in the XML correctly
- Added logic in the PAL to deal with different data structures


## Introduction

This script can be used to target a specific file type within iSite2, on any of
the environments, and update the XML to be in the latest format.

The script also maintains the 'published' and 'in progress' states of the
document so that the updated XML should transparent both on the front end and to
the editorial teams managing the data.

### Notice

At the moment the script assumes that you are on reith, the connections expect
to go through the proxy.


## Location

On your sandbox, change to the application directory

    $ cd /mnt/hgfs/workspace/kandl-migration-script


## Dependencies

You'll need to run

    $ bundle install


## Running the Script

First change to the application directory on your sandbox:

    $ cd /mnt/hgfs/workspace/kandl-migration-script

There are actually two scripts associated with this task, but both scripts have
the following command line options:

    $ -e, --environment ENVIRONMENT    The environment to update
    $ -p, --project PROJECT            The iSite2 project to query
    $ -f, --filetype FILETYPE          The iSite2 file type to update
    $ -x, --xslpath PATH TO XSL        Path of the XSL file to use for transforms
    $ -t, --threads NUMBER             The number of threads to use (default 20)
    $ -h, --help                       Display this screen


#### Download

To download Study Guide list files from the test environment:

    $ ruby -I. ./app/fetch.rb -e test -p education -f sg-study-guide-list -x path/to/study-guide-list.xsl

This will:
- download all the Study Guide lists from the test environment, in both
the 'published' and 'in progress' states,
- update the data using the provided XSLT
- place the new content in a directory for upload


#### Upload

To upload the amended Study Guide list files to the test environment:

    $ ruby -I. ./app/upload.rb -e test -p education -f sg-study-guide-list

## Tests

To run run the tests:
```
$ rspec
```
