Continuous Integration Testing
=====================================================

This docker container bundles all the needed pre-configured pieces
to experiments the Zuul gating system used by the Openstack project.
Zuul is a generic software and can be reused for other projects outside
of Openstack.

This docker container is based on a centos7 image and contains:

- Gerrit
- Zuul
- Jenkins
- Jenkins-job-builder
- Nodepool

Use Fedora 21 Cloud as Docker host
----------------------------------
We exec prep_cicd.sh for first deployment，when you want to enter into the docker instances，
you could run second_exec.sh.


### Jenkins

Only a Jenkins master is configured here.
The Jenkins Gearman plugin is pre-configured to connect on the Zuul gearman
server.

A default user "jenkins/password" is pre-configured in order to allow
to perform administrative tasks on Jenkins. This is needed in order
to use Jenkins Jobs Builder to manage jobs on Jenkins.

Jenkins Jobs Builder is pre-configured and can be used locally to update jobs.

Jenkins can be reached at http://ci.localdomain:8081/jenkins






Configure a first project to be validated via Zuul
--------------------------------------------------
1.First: you need create new project in gerrit web
2.Second: you need add your public key into your gerrit accounter 
* Login to Gerrit as the admin user. Add your public key in the admin user
  settings page. If you don't have a key yet, create one:
```
$ ssh-keygen
$ cat ~/.ssh/id_rsa.pub
```
3.you need create your jobs which you want, files in /etc/jenkins_jobs/jobs
which you could find the rule about how to describe  new jobs .
[jjb template](http://docs.openstack.org/infra/system-config/jjb.html)
when finished the definition of jobs , you could using the command to updating jenkins job.


```

# # Create a job in Jenkins for a project call "testproject"
# jenkins-jobs --conf /etc/jenkins_jobs/jenkins_jobs.ini update /etc/jenkins_jobs/jobs
```

- The job "testproject-unit-tests" must be shown in the Jenkin job list
- As admin - create a project called "testproject" in Gerrit (check "create inital empty commit")
- Clone the new project on your local computer and submit the as a review

```
$ git clone http://ci.localdomain:8080/testproject
$ cd testproject
$ git checkout -b "first_commit"
$ cat > .gitreview << EOF
[gerrit]
host=ci.localdomain
port=29418
project=testproject.git
EOF
$ cat > run_tests.sh << EOF
#!/bin/bash
exit 0
EOF
$ chmod +x run_tests.sh
$ sudo pip install git-review
$ touch "$HOME/.ssh/known_hosts"
$ ssh-keygen -f "$HOME/.ssh/known_hosts" -R [ci.localdomain]:29418
$ git review -s # use "admin" as login and be sure to have the public key listed by ssh-add -l
$ git config --add gitreview.username "admin"
$ git add run_tests.sh .gitreview
$ git commit -m "first commit"
$ git review
```

In the Gerrit web UI you should see your new patch on "testproject" and a green check
sign added by Zuul in the "Verified" label.

### Gerrit

Gerrit is configured with "DEVELOPMENT_BECOME_ANY_ACCOUNT" setting so
no need to deal with any external authentication system. Also a local H2
database is used.

Two users are created by default:

- An admin user
- A Zuul user (to allow the zuul to perform action on Gerrit)

Gerrit can be reached at http://ci.localdomain:8080

### Zuul

Zuul is pre-configured to listen to events from the Gerrit event stream
and will connect to Gerrit at container startup. Zuul's merger
git repositories are served via a pre-configured Apache.

layout.yaml is stored at /etc/zuul/layout.yaml. Two pipeline (check and gate)
are already configured.

Zuul status page can be reached at http://ci.localdomain

###nodepool

nodepool is used to interactive with openstack cloud, it cloud spwan instances according 
nodepool.yaml and scriptes which you assign,there are something must be reviewed.
Document: http://docs.openstack.org/infra/nodepool/
NOTICE:
```
cron:
  check: '*/15 * * * *'
  cleanup: '*/5 * * * *'
  image-update: '10 2 * * *'
```  
  
  
check 、cleanup and image-update means the dateline that nodepool perform the operation.
```
dburi: 'sqlite:////tmp/nodepool/nodepool'
```
It appears that you need a database which named nodepool,absolutely you could get other names.
```
gearman-servers:
  - host: 127.0.0.1

zmq-publishers:
  - tcp://127.0.0.1:8888
```
you must be check jenkins plugin,make sure gearman plugin and zmq-publishers be installed.

```
labels:
  - name: bare-trusty
    image: bare-trusty
    min-ready: 3
    providers:
      - name: centos
  - name: bare-precise
    min-ready: 3
    image: bare-precise
    providers:
      - name: centos
  - name: bare-bcec
    min-ready: 1
    image: bare-bcec
    providers:
      - name: centos
```
labels name using for bind to jenkins project, which you could create a project including 'node' key


```
providers:
  - name: centos
    auth-url: 'http://10.134.1.3:35357/v2.0'
    boot-timeout: 120
    region-name: 'RegionOne'
    service-name: 'nova'
    service-type: 'compute'
    project-id: admin
    username: 'admin'
    password: '123456'
    pool: 'cicd'
    max-servers: 15
    images:
      - name: bare-trusty
        base-image: 'centos7'
        min-ram: 4000
        name-filter: 'cicd'
        private-key: /root/.ssh/id_rsa
        setup: base.sh
        username: root
      - name: bare-precise
        base-image: 'centos7'
        name-filter: 'cicd'
        min-ram: 4000
        private-key: '/root/.ssh/id_rsa'
        setup: base.sh
        username: root
    networks:
      - net-id: 9995e58c-127d-4361-b2aa-31c21c021dfd
    availability-zones:
      - nova

net-id: you need interal-net id
pool: you provider floating-ip id

targets:
  - name: centos
    jenkins:
      apikey: xQgKJUYdM6JskzwQdSTLF_EOGNN80Cto
      credentials-id: 4f98191e-efbb-4ac4-8131-0e4a8bb2ce14
      url: http://jenkins.tests.dom:8080/jenkins/
      user: 'jenkins'
```      
apikey: it could find using jenkins web
credentials-id: find in crendentials.xml, when you create a credential ,you need put /root/.ssh/id_rsa into 
blanke and cat /roo/.ssh/id_rsa.pub into /etc/nodepool/script/ authorize_key

