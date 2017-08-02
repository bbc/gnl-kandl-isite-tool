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

    -e, --environment ENVIRONMENT    The environment to update
    -p, --project PROJECT            The iSite2 project to query
    -f, --filetype FILETYPE          The iSite2 file type to update
    -x, --xslpath PATH TO XSL        Path of the XSL file(s) to use for transforms
    -t, --threads NUMBER             The number of threads to use (default 20)
    -i, --inputpath INPUTPATH        Path containing XML documents to transform
    -o, --output OUTPUTPATH          Output path for transformed XML documents
    -h, --help                       Display this screen


#### Download

To download Study Guide list files from the test environment:

    $ ruby -I. ./app/fetch.rb -e test -p education -f sg-study-guide-list

This will:
- download all the Study Guide lists from the test environment, in both
the 'published' and 'in progress' states,
- place the new content in a directory for upload

Required arguments: environment, project, filetype

#### Download and apply transform(s)

To download Study Guide list files from the test environment:

    $ ruby -I. ./app/fetch-and-transform.rb -e test -p education -f sg-study-guide-list -x path/to/study-guide-list.xsl

This will:
- download all the Study Guide lists from the test environment, in both
the 'published' and 'in progress' states,
- update the data using the provided XSLT(s). If the path is a directory, all XSL transforms in directory will be applied in alphanumerically sorted order.
- place the new content in a directory for upload

Required arguments: environment, project, filetype, xslpath

### Apply transform(s)

#### Configuration

The transform script uses a yml file to setup the required parameters. Doing it in this way means the yml file can be versioned alongside the xsl and xsd for the transform. The benefit of this is that the command is simpler to run and easily reproducible in the future.

The YML file should be of the following format:
```
filetype:
source:
target:
xsl:
xsd:
```

- `filetype` should match the File Type in iSite that you're looking to transform.
- `source` is the parent directory where the documents have previously been downloaded to. Use a regular-expression match on sub-directories and filenames.
- `target` is the parent directory of where you want the transformed documents output to. Use a regular-expression value on sub-directories and filenames so it corresponds to the source directory.
- `xsl` is the full path to the XSL file you want to use to transform the source documents.
- `xsd` is the full path to the XSD file you want to use to validate the transformed documents.

An example config is:
```
filetype: sg-video-chapter
source: extracted/**/*.xml
target: transformed/**/*.xml
xsl: /mnt/hgfs/workspace/kandlcurriculum/isite2/templates/migrations/sg-video-chapter/001-all-elements-within-a-container/transform.xsl
xsd: /mnt/hgfs/workspace/kandlcurriculum/isite2/templates/migrations/sg-video-chapter/001-all-elements-within-a-container/schema.xsd
```

#### The Command

To run the transform

    $ ruby ./transform.rb -e :environment -c :config

where `:environment` is test, stage or live and relates to the environment that the files were obtained from
  and `:config` is the full path to the yml file as defined above


#### Upload

To upload the amended Study Guide list files to the test environment:

    $ ruby -I. ./app/upload.rb -e test -p education -f sg-study-guide-list

Required arguments: environment, project, filetype

## Tests

To run the tests:
```
$ rspec
```
