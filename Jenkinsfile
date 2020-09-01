pipeline {
  environment {
    registry = 'cldops/centime'
    registryCredential = 'jenkins-dockerhub'
    app = ''
  }
  agent any
  stages {
    stage('clone SCM') {
      steps {
        checkout scm
      }
    }
    stage('maven build') {
      steps {
        script{
          withMaven(maven: 'mvn') {
            sh "mvn clean package"
          }
        }
      }
    }
    stage('Build dockerimage') {
      steps{
        script{
          app = docker.build(registry + ":$BUILD_NUMBER")
      }
     }
    }
    stage('Push Image') {
      steps{
        script{
          docker.withRegistry( '', registryCredential ) {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
       }
      }
    }
    stage('Deploy Image') {
      steps{
        sh "chmod +x manifests/modifytag.sh"
        sh "./manifests/modifytag.sh $BUILD_NUMBER"
        sh "kubectl apply -f manifests/mongo.yml"
        sh "kubectl apply -f manifests/deploy.yml"
        sh "kubectl apply -f manifests/service.yml"
      }
    }
    stage('Remove Unused docker image') {
      steps{
        sh "docker rmi $registry:$BUILD_NUMBER"
      }
    }
  }
}
