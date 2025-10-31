pipeline {
  agent any

  environment {
    HARBOR_REGISTRY = 'harbor.server.thweb.click'
    HARBOR_PROJECT = 'tthau'
    IMAGE_NAME = 'boardgame'
    IMAGE_TAG = '${BUILD_NUMBER}'
    HARBOR_CREDS = credentials('jenkins-harbor-credentials')
  }

  stages {
    stage('Checkout') {
      steps {
        echo '📥 Checking out code from GitLab...'
        checkout scm
      }
    }

    stage('Build Maven') {
      agent {
        docker {
          image 'maven:3.8.5-openjdk-11'
          args '-v $HOME/.m2/root/.m2'
        }
      }
      steps {
        sh 'mvn clean package -DskipTests'
      }
    }
  }

    stage('Test') {
      agent {
        docker {
          image 'maven:3.8.5-openjdk-11'
          args '-v $HOME/.m2/root/.m2'
        }
      }
      steps {
        sh 'mvn test'
      }
      post {
          always {
              junit '**/target/surefire-reports/*.xml'
              jacoco execPattern: '**/target/jacoco.exec'
          }
          success {
              echo '✅ All tests passed'
          }
          failure {
              echo '❌ Tests failed - check reports'
          }
      }
    }
  }


  post {
    success {
      echo '✅ Pipeline completed succesfully!!'
    }
    failure {
      echo "❌ Pipeline failed"
    }
    always {
      echo '🧹 Cleaning workspace'
      // cleanWs()
    }
  }
}