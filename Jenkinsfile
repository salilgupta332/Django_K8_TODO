// pipeline {
//     agent any
//     stages {
//         stage('Git checkout') {
//             steps {
//                 git url: "https://github.com/salilgupta332/Practice.git", branch: "main"
//             }
//         }

//         stage("Send files to EC2") {
//             steps {
//                 sshagent(['ansible']) {
//                     sh "ssh-keyscan -H 13.201.116.121 >> ~/.ssh/known_hosts"
//                     sh "scp -o StrictHostKeyChecking=no -r /var/lib/jenkins/workspace/Djan/* ubuntu@13.201.116.121:/home/ubuntu/"
//                 }
//             }
//         }

//         stage("Build Docker image on EC2") {
//             steps {
//                 sshagent(['ansible']) {
//                     sh "ssh -o StrictHostKeyChecking=no ubuntu@13.201.116.121 'cd /home/ubuntu && docker build -t djan:v1.${BUILD_ID} .'"
//                 }
//             }
//         }

//         stage("Image Tagging") {
//             steps {
//                 sshagent(['ansible']) {
//                     sh "ssh -o StrictHostKeyChecking=no ubuntu@13.201.116.121 'docker tag djan:v1.${BUILD_ID} devops22003/djan:v1.${BUILD_ID}'"
//                     sh "ssh -o StrictHostKeyChecking=no ubuntu@13.201.116.121 'docker tag djan:v1.${BUILD_ID} devops22003/djan:latest'"
//                 }
//             }
//         }

//         stage("Pushing image to Docker Hub") {
//             steps {
//                 sshagent(['ansible']) {
//                     echo 'Pushing Image to Docker hub'
//                     withCredentials([usernamePassword(credentialsId:"dockerhub", passwordVariable: "dockerHubPass", usernameVariable: "dockerHubUser")]) {
//                         sh "ssh -o StrictHostKeyChecking=no ubuntu@13.201.116.121 'docker login -u ${dockerHubUser} -p ${dockerHubPass}'"
//                         sh "ssh -o StrictHostKeyChecking=no ubuntu@13.201.116.121 'docker push devops22003/djan:v1.${BUILD_ID}'"
//                         sh "ssh -o StrictHostKeyChecking=no ubuntu@13.201.116.121 'docker push devops22003/djan:latest'"
//                     }
//                 }
//             }
//         }
//         stage("Copy files from ansible to kubernetes server") {
//             steps{
//                 sshagent(['k8_key']) {
//                         sh "ssh -o StrictHostKeyChecking=no  ubuntu@172.31.3.122 'echo Connected to K8s server'" 
//                         sh "scp -o StrictHostKeyChecking=no -r /var/lib/jenkins/workspace/Djan/* ubuntu@172.31.3.122:/home/ubuntu/"
//         }

//             }
//         }
//         stage("Kubernetes Deployment using Ansible") {
//             steps {
//                 sshagent(['ansible']) {
//                     sh "ssh -o StrictHostKeyChecking=no ubuntu@172.31.45.90 'cd /home/ubuntu/' "
//                     sh "ssh -o StrictHostKeyChecking=no ubuntu@172.31.45.90 'ansible-playbook ansible.yml' "

                    
//                 }
//             }
//         }
//     }
// }









pipeline {
    agent any
    environment {
        ANSIBLE_SERVER = "172.31.39.39"
        ANSIBLE_PRIVATE_IP="172.31.39.39"
        K8S_SERVER = "172.31.35.98"
        WORKSPACE_DIR = "/var/lib/jenkins/workspace/todo_pipeline"
    }
    stages {
        stage('Git checkout') {
            steps {
                git url: "https://github.com/salilgupta332/Practice.git", branch: "main"
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
        stage("Image Tagging") {
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
                    withCredentials([usernamePassword(credentialsId:"dockerhub", passwordVariable: "dockerHubPass", usernameVariable: "dockerHubUser")]) {
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@${ANSIBLE_SERVER} 'docker login -u ${dockerHubUser} -p ${dockerHubPass}'"
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@${ANSIBLE_SERVER} 'docker push devop0502/$JOB_NAME:v1.${BUILD_ID}'"
                        sh "ssh -o StrictHostKeyChecking=no ubuntu@${ANSIBLE_SERVER} 'docker push devop0502/$JOB_NAME:latest'"
                    }
                }
            }
        }

        stage("Copy files from ansible to kubernetes server") {
            steps{
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