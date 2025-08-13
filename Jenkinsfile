pipeline {
    agent any
    stages {
        stage('Git checkout') {
            steps {
                git url: "https://github.com/salilgupta332/Practice.git", branch: "main"
            }
        }

        stage("Send files to EC2") {
            steps {
                sshagent(['ansible']) {
                    sh "ssh-keyscan -H 13.201.116.121 >> ~/.ssh/known_hosts"
                    sh "scp -o StrictHostKeyChecking=no -r /var/lib/jenkins/workspace/Djan/* ubuntu@13.201.116.121:/home/ubuntu/"
                }
            }
        }

        stage("Build Docker image on EC2") {
            steps {
                sshagent(['ansible']) {
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@13.201.116.121 'cd /home/ubuntu && docker build -t djan:v1.${BUILD_ID} .'"
                }
            }
        }

        stage("Image Tagging") {
            steps {
                sshagent(['ansible']) {
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@13.201.116.121 'docker tag djan:v1.${BUILD_ID} devops22003/djan:v1.${BUILD_ID}'"
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@13.201.116.121 'docker tag djan:v1.${BUILD_ID} devops22003/djan:latest'"
                }
            }
        }

        stage("Pushing image to Docker Hub") {
            steps {
                sshagent(['ansible']) {
                    echo 'Pushing Image to Docker hub'
                    withCredentials([usernamePassword(credentialsId:"dockerhub", passwordVariable: "dockerHubPass", usernameVariable: "dockerHubUser")]) {
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@13.201.116.121 'docker login -u ${dockerHubUser} -p ${dockerHubPass}'"
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@13.201.116.121 'docker push devops22003/djan:v1.${BUILD_ID}'"
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@13.201.116.121 'docker push devops22003/djan:latest'"
                    }
                }
            }
        }
        stage("Copy files from ansible to kubernetes server") {
            steps{
                sshagent(['k8_key']) {
                        sh "ssh -o StrictHostKeyChecking=no  ubuntu@172.31.3.122 'echo Connected to K8s server'" 
                        sh "scp -o StrictHostKeyChecking=no -r /var/lib/jenkins/workspace/Djan/* ubuntu@172.31.3.122:/home/ubuntu/"
        }

            }
        }
        stage("Kubernetes Deployment using Ansible") {
            steps {
                sshagent(['ansible']) {
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@172.31.45.90 'cd /home/ubuntu/' "
                    sh "ssh -o StrictHostKeyChecking=no ubuntu@172.31.45.90 'ansible-playbook ansible.yml' "

                    
                }
            }
        }
    }
}
