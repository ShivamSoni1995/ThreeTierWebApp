# Building a 3-Tier Web Application with AWS Infrastructure

## Description

This project demonstrates the architecture and implementation of a highly available, scalable, and secure 3-tier web application using Amazon Web Services (AWS). The application is divided into three distinct layers:

1.  **Web/Presentation Tier**: Handles user interface and interaction (Frontend).
2.  **Application Tier**: Contains the business logic and backend processing.
3.  **Data Tier**: Manages data storage and retrieval, typically using databases.

The infrastructure is designed to run across multiple Availability Zones (AZs) within an AWS region to enhance fault tolerance and availability.

## Architecture Overview

The application follows a standard 3-tier architecture deployed within a custom AWS Virtual Private Cloud (VPC):

* **VPC**: A logically isolated network spanning two Availability Zones.
* **Web Tier**:
    * Located in public subnets across two AZs.
    * Uses EC2 instances running Apache web servers, managed by an Auto Scaling Group (ASG).
    * An internet-facing Application Load Balancer (ALB) distributes incoming HTTP/S traffic to the web servers.
    * A Bastion Host in a public subnet provides secure SSH access to instances in private subnets.
* **Application Tier**:
    * Located in private subnets across two AZs.
    * Uses EC2 instances for backend application logic, managed by an ASG.
    * An internal Application Load Balancer (ALB) distributes traffic from the Web Tier to the application servers.
    * Instances use a NAT Gateway in a public subnet for outbound internet access (e.g., for updates).
* **Data Tier**:
    * Located in separate private subnets across two AZs for high availability.
    * Uses Amazon RDS (MySQL) database instance(s).
    * Access is restricted to the Application Tier via security groups.

*(See the diagrams in the source document for a visual representation).*

## Features

* **High Availability**: Deployed across multiple Availability Zones.
* **Scalability**: Utilizes Auto Scaling Groups (ASGs) to automatically adjust the number of EC2 instances based on demand (configured with CPU utilization target tracking).
* **Security**:
    * Network segmentation using public and private subnets.
    * Security Groups acting as firewalls to control traffic between tiers and from the internet.
    * Bastion host for secure administrative access to private instances.

## Prerequisites

* An AWS account with appropriate IAM user permissions.
* Familiarity with the AWS Management Console.
* Working knowledge of:
    * VPC networking concepts (subnets, route tables, gateways).
    * EC2 instances, Auto Scaling Groups, Application Load Balancers.
    * Security Groups.
    * RDS.
* Basic understanding of Linux commands, scripting (Bash), and SSH.
* Access to a command-line interface (terminal or shell).
* An SSH key pair for connecting to EC2 instances.

## Setup and Deployment Steps

*(Refer to the source document "Building a 3 tier web application with AWS infrastructure.pdf" for detailed, step-by-step instructions with screenshots.)*

1.  **Network Foundation**:
    * Create VPC with public and private subnets across two AZs.
    * Configure Internet Gateway (IGW) and associate it with the public route table.
    * Create NAT Gateway(s) in public subnet(s) and associate with private route table(s).
    * Configure route tables for public and private subnets.
    * Enable auto-assign public IPs for public subnets.
2.  **Web Tier**:
    * Create a Security Group allowing HTTP (80), HTTPS (443) from anywhere, and SSH (22) from your IP.
    * Create an EC2 Launch Template using Amazon Linux 2, t2.micro instance type, associate the SSH key pair, and configure user data to install/start Apache.
    * Create an Auto Scaling Group using the launch template, targeting the public subnets, with desired/min/max instances (e.g., 2/2/5).
    * Configure an internet-facing Application Load Balancer targeting the ASG instances, listening on HTTP port 80.
    * Set up target tracking scaling policy for the ASG (e.g., based on CPU utilization).
    * Ensure the ALB uses the correct web server security group.
3.  **Application Tier**:
    * Create a Security Group allowing necessary traffic (e.g., ICMP from Web Tier SG for ping tests, SSH from Bastion Host SG, MySQL/Aurora access to/from DB Tier SG).
    * Create an EC2 Launch Template similar to the Web Tier, but configure user data to install necessary application dependencies (e.g., MySQL client).
    * Create an Auto Scaling Group using this template, targeting the *private* application subnets.
    * Configure an *internal* Application Load Balancer targeting the App Tier ASG instances, listening on an appropriate port (e.g., HTTP 80).
4.  **Bastion Host**:
    * Create a Security Group allowing SSH (22) only from your IP.
    * Launch a single EC2 instance (e.g., t2.micro) in a *public* subnet using the Bastion SG and your SSH key pair.
    * Modify the Application Tier Security Group to allow SSH *only* from the Bastion Host Security Group.
5.  **Data Tier**:
    * Create a Security Group allowing inbound MySQL/Aurora traffic (port 3306) *only* from the Application Tier Security Group.
    * Create an RDS DB Subnet Group using the *private* database subnets across multiple AZs.
    * Launch an RDS MySQL instance (e.g., db.t2.micro for Free Tier), associate it with the DB Subnet Group and DB Security Group, disable Public Access, and set master credentials.
6.  **Connectivity Testing**:
    * Verify web server access via the Web Tier ALB DNS name.
    * SSH into a web server instance and ping a private IP of an application server instance.
    * Use SSH Agent Forwarding to SSH into the Bastion Host, then from the Bastion Host, SSH into a private application server instance.
    * From an application server instance, connect to the RDS database endpoint using the MySQL client and the master credentials.

## Technologies Used

* **AWS Services**:
    * VPC (Virtual Private Cloud)
    * EC2 (Elastic Compute Cloud)
    * Auto Scaling Groups (ASG)
    * Application Load Balancer (ALB)
    * RDS (Relational Database Service - MySQL)
    * NAT Gateway
    * Internet Gateway
    * Security Groups
    * IAM (Implicitly for access)
* **Software**:
    * Linux (Amazon Linux 2)
    * Apache Web Server
    * MySQL Client
    * SSH

## Cleanup

To avoid ongoing charges, ensure you delete all the AWS resources created during this project deployment. This includes:

* Auto Scaling Groups (Web and Application Tiers)
* Application Load Balancers (Web and Application Tiers)
* EC2 Instances (including the Bastion Host)
* RDS Database Instance
* NAT Gateway(s)
* Release any allocated Elastic IP addresses
* Internet Gateway
* VPC (ensure all dependent resources are deleted first)
