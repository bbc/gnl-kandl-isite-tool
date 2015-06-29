Curriculum
===============

http://bbc.co.uk/education

https://production.bbc.co.uk/isite2/p/education


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

Change to the application directory

    $ cd /mnt/hgfs/workspace/kandl-migration-script


## Dependencies

You'll need to run

    $ bundle install


## Running the Script

Firstly change to the application directory:

    $ cd /mnt/hgfs/workspace/kandl-migration-script

There are actually two scripts associated with this task, but both scripts have
the following command line options:

    $ -e, --environment ENVIRONMENT    The environment to update
    $ -p, --project PROJECT            The iSite2 project to query
    $ -f, --filetype FILETYPE          The iSite2 file type to update
    $ -t, --threads NUMBER             The number of threads to use (default 20)
    $ -h, --help                       Display this screen


#### Download

To download Study Guide list files from the test environment:

    $ ruby -I. ./app/fetch.rb -e test -p education -f sg-study-guide-list

This will:
- download all the Study Guide lists from the test environment, in both
the 'published' and 'in progress' states,
- update the data using the approppriate XSLT
- place the new content in a directory for upload


#### Upload

To upload the amended Study Guide list files to the test environment:

    $ ruby -I. ./app/upload.rb -e test -p education -f sg-study-guide-list


## The Templates

There are XML and XSLT files located in the templates directory:

    $ cd app/templates

Each file is named after the iSite2 'File type Id', in the admin section.

#### The XML Template

The XML file is present to show how the XML was structured when the XSLT was
created. Then if the XML is changed, the new XML can be added in and it'll
highlight what changes need to be made in the XSLT.

#### The XSL Template

The XSLT files are self explanatory. If creating a new XSLT then do look at how
the existing XSLT documents are setting their namespaces.

