pipeline {
    agent any
    environment {
        ANSIBLE_SERVER = "35.154.33.146"
        ANSIBLE_PRIVATE_IP = "172.31.39.39"
        K8S_SERVER = "172.31.35.98"
        WORKSPACE_DIR = "/var/lib/jenkins/workspace/todo_pipeline"
    }
    stages {
        stage('Git checkout') {
            steps {
                git url: "https://github.com/salilgupta332/Django_K8_TODO.git", branch: "main"
            }
        }
        stage("Sending Docker file to ansible server") {
            steps {
                sshagent(['ansible']) {
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@${ANSIBLE_SERVER}"
                    sh "scp -o StrictHostKeyChecking=no -r ${WORKSPACE_DIR}/* ubuntu@${ANSIBLE_SERVER}:/home/ubuntu/"
                }
            }
        }
        stage("Build Docker image on EC2") {
            steps {
                sshagent(['ansible']) {
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@${ANSIBLE_SERVER} 'cd /home/ubuntu && docker image build -t $JOB_NAME:v1.${BUILD_ID} .'"
                }
            }
        }
        stage("Image Tagging"){
            steps {
                sshagent(['ansible']) {
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@${ANSIBLE_SERVER} 'docker image tag $JOB_NAME:v1.${BUILD_ID} devop0502/$JOB_NAME:v1.${BUILD_ID}'"
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@${ANSIBLE_SERVER} 'docker image tag $JOB_NAME:v1.${BUILD_ID} devop0502/$JOB_NAME:latest'"
                }
            }
        }
        stage("Pushing image to Docker Hub") {
            steps {
                sshagent(['ansible']) {
                    echo 'Pushing Image to Docker hub'
                    withCredentials([usernamePassword(credentialsId: "dockerhub", passwordVariable: "dockerHubPass", usernameVariable: "dockerHubUser")]) {
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@${ANSIBLE_SERVER} 'docker login -u ${dockerHubUser} -p ${dockerHubPass}'"
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@${ANSIBLE_SERVER} 'docker push devop0502/$JOB_NAME:v1.${BUILD_ID}'"
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@${ANSIBLE_SERVER} 'docker push devop0502/$JOB_NAME:latest'"
                    }
                }
            }
        }
        stage("Copy files from ansible to kubernetes server") {
            steps {
                sshagent(['ansible']) {
                    sh "ssh -o StrictHostKeyChecking=no  ubuntu@${K8S_SERVER} 'echo Connected to K8s server'"
                    sh "scp -o StrictHostKeyChecking=no -r ${WORKSPACE_DIR}/* ubuntu@${K8S_SERVER}:/home/ubuntu/project/"
                }
            }
        }
        stage("Kubernetes Deployment using Ansible") {
            steps {
                sshagent(['ansible']) {
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@${ANSIBLE_PRIVATE_IP} 'cd /home/ubuntu/' "
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@${ANSIBLE_PRIVATE_IP} 'ansible-playbook ansible.yml' "
                }
            }
        }
    }
}