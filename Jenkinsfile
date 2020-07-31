def GitVersion_SemVer = ''
def GitVersion_FullSemVer = ''
def TAG_SEM_VERSION = 'No Release'

pipeline {
    environment {
        DEPLOY = "${env.BRANCH_NAME == "master" || env.BRANCH_NAME == "develop" ? "true" : "false"}"
        NAME = "${env.BRANCH_NAME == "master" ? "qsync" : "qsync-dev"}"
        DOMAIN = 'localhost'
    }
    agent any


    stages {
        stage('Get Git Version') {
            steps {
               sh 'printenv'
               withCredentials([usernamePassword(credentialsId: 'github', passwordVariable: 'bitpass', usernameVariable: 'bituser')]) {
                 sh(script: 'gitversion . /output buildserver /url https://github.com/AndrewRoesch/PrestaShop /u $bituser /p $bitpass /b $BRANCH_NAME')
               }
               script {
                   
                   def d = [test: 'Default', something: 'Default', other: 'Default']
                   def props = readProperties defaults: d, file: 'gitversion.properties', text: 'other=Override'
                   GitVersion_FullSemVer= props['GitVersion_FullSemVer']
                   GitVersion_SemVer= props['GitVersion_SemVer']
                  
                   echo "GitVersion_FullSemVer=${GitVersion_FullSemVer}"
                   echo "GitVersion_SemVer=${GitVersion_SemVer}"
                   
                   TAG_SEM_VERSION = "${GitVersion_SemVer}-${env.BUILD_NUMBER}"
            
               }
            }
        }
        stage('Push Container') {
            steps {
               
               echo "TAG_SEM_VERSION=${TAG_SEM_VERSION}"
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub') {
                        def image = docker.build("andrewroesch/prestashop:'${TAG_SEM_VERSION}'", '. ')
                        image.push()
                        image.push('latest')
                    }
                }
            }
        }
    }
    post {
        success {
            googlechatnotification message: "Prestashop Build Passed '${TAG_SEM_VERSION}'", notifyFailure: true, notifySuccess: true, url: 'https://chat.googleapis.com/v1/spaces/AAAAMXwY8kA/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=lQoJYQMIr4tG3p11LSuUQC-wjnF94P4mSn38SBhZ5mw%3D'

        }
        failure {
            googlechatnotification message: "Prestashop Build Failed '${TAG_SEM_VERSION}'", notifyFailure: true, notifySuccess: true, url: 'https://chat.googleapis.com/v1/spaces/AAAAMXwY8kA/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=lQoJYQMIr4tG3p11LSuUQC-wjnF94P4mSn38SBhZ5mw%3D'

        }
    }
}