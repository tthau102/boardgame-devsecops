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
      steps {
        sh '''
          # Show Java/Maven version
          java -version
          ./mvnw --version

          # Clean Build
          ./mvnw clean package -DskipTests

          # Verify JAR created
          ls -lh target/*.jar
        '''
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
      cleanWs()
    }
  }
}