#!/usr/bin/env groovy
/**
  ***** Dminds Devops ToolChain *****
  Documentation: https://
  Status: Continouse Improvement 
https://groovy-lang.org/semantics.html
*/
import org.jenkinsci.plugins.pipeline.modeldefinition.Utils

node {
    checkout scm
    deleteDir()
}

def seperator60 = '\u2739' * 60
def seperator20 = '\u2739' * 20
def seperator30 = '\u2739' * 30

node() {

    stage('Bring Up Fe') {
        echo "${seperator60}\n${seperator20} Spinning up frontend \n${seperator60}"
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "admin_preprod",
            accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
            wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']){
                    dir("./infra/live_fe"){
                        sh """
                            terraform init 
                            terraform fmt 
                            terraform validate
                            terraform plan
                            terraform apply -auto-approve 
                        """
                    } 
            }
        }
    }

    stage('Bring Up Be') {
        echo "${seperator60}\n${seperator20} Spinning up backend \n${seperator60}"
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "admin_preprod",
            accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
            wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']){
                    dir("./infra/live_be"){
                        sh """
                            terraform init 
                            terraform fmt 
                            terraform validate
                            terraform plan
                            terraform apply -auto-approve 
                        """
                    } 
            }
        }
    }

    stage("CheckPoint") {
        input 'Continue deployement to backend ?'
    }

    stage('Prep Mangement VPC') {
        echo "${seperator60}\n${seperator20} Simple deployment \n${seperator60}"
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "admin_preprod",
            accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
        ]]) {
            wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'xterm']){
                    dir("./deployer/be"){
                        sh """
                            ansible-playbook -i hosts.inv main.yaml --private-key=preprod.pem 
                        """
                    } 
            }
        }
    }
    
}