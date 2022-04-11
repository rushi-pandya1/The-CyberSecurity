## Automated ELK Stack Deployment

The files in this repository were used to configure the network depicted below.

![Cloud Security Project](Diagrams/Cloud_Security_Project.jpg)

These files have been tested and used to generate a live ELK deployment on Azure. They can be used to either recreate the entire deployment pictured above. Alternatively, select portions of the Filebeat playbook file may be used to install only certain pieces of it, such as Filebeat.

  - Config file for Ansible Container: [Ansible Config file](Ansible/ansible.cfg)
  - Config file for DVWA Hosts: [DVWA Hosts Config file](Ansible/hosts)
  - Playbook to Install DVWA Container: [DVWA playbook](Ansible/dvwa.yml)
  - Playbook to Install ELK Container: [ELK playbook](Ansible/install-elk.yml)
  - Config Playbook for Filebeat: [Filebeat Config playbook](Ansible/filebeat-config.yml)
  - Playbook to Install Filebeat: [Filebeat Installation playbook](Ansible/filebeat-playbook.yml)
  - Config Playbook for Metricbeat: [Metricbeat Config playbook](Ansible/metricbeat-config.yml)
  - Playbook to Install Metricbeat: [Metricbeat Installation playbook](Ansible/metricbeat-playbook.yml)

This document contains the following details:
- [Description of the Topology](https://github.com/rushi-pandya1/The-CyberSecurity#description-of-the-topology)
- [Access Policies](https://github.com/rushi-pandya1/The-CyberSecurity#access-policies)
- [ELK Configuration](https://github.com/rushi-pandya1/The-CyberSecurity#elk-configuration)
 - [Machines Being Monitored](https://github.com/rushi-pandya1/The-CyberSecurity#machines-being-monitored)
 - [Beats in Use](https://github.com/rushi-pandya1/The-CyberSecurity#beats-in-use)
- [How to Use the Ansible Build](https://github.com/rushi-pandya1/The-CyberSecurity#how-to-use-the-ansible-build)


### Description of the Topology

The main purpose of this network is to expose a load-balanced and monitored instance of DVWA, the D*mn Vulnerable Web Application.

Load balancing ensures that the application will be highly available and redundant, in addition to restricting traffic overload to the network.
Load balancer reduces downtime by equally distributing traffic between servers and protects "availability" aspect of security.
Jump box sits in front of other machines in network so only Jump box is exposed to public internet.
Jump box controls access to other network machines by allowing traffic from specific addresses and then forwarding to network machines based on Security rules.

Integrating an ELK server allows users to easily monitor the vulnerable VMs for changes to the network and system logs and files.
  - What does Filebeat watch for?
  > Filebeat watch for files which are changed and when the changes are made. Filebeat starts one or more input to look for data logs in specified locations and for each log filebeat finds, it starts harvester which reads a single log for new content and sends the new log data to libbeat, which collects all the events and sends the aggregated data to the logstash or Elasticsearch for indexing.
  - What does Metricbeat record?
  > Metricbeat periodically records metrics from services and operating system running on the server like Apache, MySQL, Nginx, MongoDB, System module, HAProxy, PostgreSQL, Redis, Zookeeper. It collects all the metrics and statistics and forwards them to the Elasticsearch or Logstash.

The configuration details of each machine may be found below:

| Name     | Function          | IP Address | Operating System |
|----------|-------------------|------------|------------------|
| Jump Box | Gateway           | 10.1.0.4   | Linux            |
| WebVM1   | Web Server        | 10.1.0.5   | Linux            |
| WebVM2   | Web Server        | 10.1.0.6   | Linux            |
| ELK-VM   | Monitoring Server | 10.2.0.4   | Linux            |

### Access Policies

The machines on the internal network are not exposed to the public Internet. 

Only the Jump Box machine can accept connections from the Internet. Access to this machine is only allowed from the following IP addresses:
- Allowed Source IP Address inbound to Jump Box: 72.137.73.237

Machines within the network can only be accessed by My workstation with IP Address 72.137.73.237 through SSH into Jump Box and Jump Box have access to entire network.
Jump Box can SSH to ELK Server on port 22. My workstation with IP Address 72.137.73.237 can also access ELK Server on port 5601.

A summary of the access policies in place can be found in the table below.

| Name     | Publicly Accessible | Allowed IP Addresses                        | Open Ports          |
|----------|---------------------|---------------------------------------------|---------------------|
| Jump Box | Yes                 | 72.137.73.237                               | 22                  |
| WebVM1   | No                  | 10.1.0.4                                    | 80, 22              |
| WebVM2   | No                  | 10.1.0.4                                    | 80, 22              |
| ELK-VM   | Yes                 | 72.137.73.237, 10.1.0.4, 10.1.0.5, 10.1.0.6 | 5601, 22, 9200-9300 |

### Elk Configuration

Ansible was used to automate configuration of the ELK machine. No configuration was performed manually, which is advantageous because it reduces potential for human error and also simplifies to configure many machines identically at same time.

The playbook implements the following tasks:
- Step-1: Use "apt" module to install docker.io and python3-pip (Will use "update_cache" otherwise docker.io will not install, "update_cache" is equivalent to running "apt update" on command line)
   ``` 
     - name: Install docker.io
      apt:
        update_cache: yes
        force_apt_get: yes
        name: docker.io
        state: present

    - name: Install python3-pip
      apt:
        force_apt_get: yes
        name: python3-pip
        state: present
   ``` 
- Step-2: Use "pip" module to install docker
   ```
    - name: Install Docker module
      pip:
        name: docker
        state: present
   ```
- Step-3: Use "command" module to increase virtual memory and command is "sysctl -w vm.max_map_count=262144"
   ```
    - name: Increase virtual memory
      command: sysctl -w vm.max_map_count=262144
   ```
- Step-4: Use "sysctl" module to use more memory and use memory size by putting value "262144" for "vm.max_map_count" and putting "yes" for "reload" option
   ```
    - name: Use more memory
      sysctl:
        name: vm.max_map_count
        value: '262144'
        state: present
        reload: yes
   ```
- Step-5: Use "docker_container" module to download and launch docker elk container, image is "sebp/elk:761" ('sebp' is organization that made 'elk' container and '761' is version number)
   ```
    - name: download and launch a docker elk container
      docker_container:
        name: elk
        image: sebp/elk:761
        state: started
        restart_policy: always
   ```
- Step-6: Use "published_ports" module along with "docker_container" module for port mappings to list ports that ELK server runs on, which are 5601, 9200, 5044
   ```
        published_ports:
          -  5601:5601
          -  9200:9200
          -  5044:5044
   ```
- Step-7: Use "systemd" module to automatically "enable" docker service when ELK VM restarts
   ```
    - name: Enable service docker on boot
      systemd:
        name: docker
        enabled: yes
   ```

The following screenshots displays the result of running `docker ps` after successfully configuring the ELK instance.

- ELK Docker Container
![Screenshot for ELK Docker list](Diagrams/ELK_Docker.png)
- WebVM1 Docker Container
![Screenshot for WebVM1 Docker list](Diagrams/WebVM1_Docker.png)
- WebVM1 Docker Container
![Screenshot for WebVM2 Docker list](Diagrams/WebVM2_Docker.png)
- Jump Box Docker Container
![Screenshot for Jump Box Docker list](Diagrams/Jump_Box_Docker.png)

### Target Machines & Beats
This ELK server is configured to monitor the following machines:
- WebVM1: 10.1.0.5
- WebVM2: 10.1.0.6

We have installed the following Beats on these machines:
- Filebeat
![Screenshot for Filebeat](Diagrams/Filebeat.png)
- Metricbeat
![Screenshot for Metricbeat](Diagrams/Metricbeat.png)

These Beats allow us to collect the following information from each machine:
- Filebeat collects information like Syslog events & logs, Sudo Commands Usage, SSH logins, New Users and Groups. Example: Sudo Commands logs include statistics like Top Sudo Commands, Sudo Commands by Users
- Metricbeat collects information like System Overview, Hosts Overview, Container Overview. Example: System Overview logs include statistics like Top Hosts by CPU, Top Hosts by Memory, Inbound & Outbound traffic

### Using the Playbook
In order to use the playbook, you will need to have an Ansible control node already configured. Assuming you have such a control node provisioned:

SSH into the control node and follow the steps below:
- Copy the [ELK Playbook](Ansible/install-elk.yml) file to /etc/ansible folder in Ansible container.
- Update the [Hosts](Ansible/hosts) file to include IP Address for webserver and ELK server.
- Run the playbook, and navigate to Kibana web app to check that the installation worked as expected. To reach Kibana web app use Elk Server's IP Address:5601/app/kibana
