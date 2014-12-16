Nuxeo.io systemd journal wrapper to CloudWatch Logs
===================================================

This repository holds the Dockerfile for our journald wrapper to [Amazon CloudWatch Logs](http://aws.amazon.com/about-aws/whats-new/2014/07/10/introducing-amazon-cloudwatch-logs/).

Notes
-----

This container is designed to be run over a [CoreOS](https://coreos.com/) system, due to his dependency on Etcd. Etcd is used to held last logs pushed, stored under `/config/journald/{node_id}/cursor`.

Also, it needs the service `[systemd-journal-gatewayd.service](http://www.freedesktop.org/software/systemd/man/systemd-journal-gatewayd.service.html)` to be started, that exposes journald logs throught a webpage allowing to use [Server-Sent Events](https://developer.mozilla.org/en-US/docs/Server-sent_events/Using_server-sent_events).

Improvements
-----------

 - Make the script available as a gem, using a gemfile to install container dependencies.
 - Extract some concepts like; abstract the store used for the last cursor, stack events before sending them to AWS, ...
 - Make it less dependends of an EC2 instance

Running this container
----------------------

    # Ensure to have start `systemd-journal-gatewayd.service` service
    sudo systemctl start systemd-journal-gatewayd.service

    # build container
    docker build -t journald_wrapper .

    # run container
    docker run -d -e AWS_ACCESS_KEY_ID={YOUR_KEY_ID} -e AWS_SECRET_ACCESS_KEY={YOUR_SECRET} -e AWS_REGION={YOUR_REGION} -e PREFIX={A_PREFIX_IDENTIFIER} journald_wrapper

About Nuxeo
-----------

Nuxeo provides a modular, extensible Java-based
[open source software platform for enterprise content management](http://www.nuxeo.com/en/products/ep),
and packaged applications for [document management](http://www.nuxeo.com/en/products/document-management),
[digital asset management](http://www.nuxeo.com/en/products/dam) and
[case management](http://www.nuxeo.com/en/products/case-management).

Designed by developers for developers, the Nuxeo platform offers a modern
architecture, a powerful plug-in model and extensive packaging
capabilities for building content applications.

More information on: <http://www.nuxeo.com/>
