pipeline {
    agent any

    options {
        ansiColor('xterm')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: "GitSCM",
                    branches: [[name: "*/${BRANCH}"]],
                    doGenerateSubmoduleConfigurations: scm.doGenerateSubmoduleConfigurations,
                    extensions: scm.extensions,
                    userRemoteConfigs: scm.userRemoteConfigs
                ])
                sh "git checkout ${BRANCH}"
                sh "git reset --hard origin/${BRANCH}"
            }
        }

        stage('Dependencies') {
            steps {
                sh "bundle install"
            }
        }

        stage('Bump version') {
            steps {
                sh "bundle exec fastlane bump_version version:${params.VERSION}"
            }
        }

        stage('Build') {
            steps {
                sh "bundle exec fastlane build configuration:${params.CONFIGURATION}"
            }
        }

        stage('Test') {
            when {
                expression { params.RUN_TESTS }
            }
            steps {
                sh "bundle exec fastlane test"
            }
        }

        stage('Deliver') {
            when {
                expression { params.DELIVER }
            }
            steps {
                sh "bundle exec fastlane release_to_testflight configuration:${params.CONFIGURATION}"
            }
        }

        stage('Commit') {
            steps {
                sh "bundle exec fastlane commit_version version:${params.VERSION}"
            }
        }

        stage('Tag') {
            when {
                expression { params.DELIVER }
            }
            steps {
                sh "bundle exec fastlane tag_version version:${params.VERSION}"
            }
        }
    }
}
