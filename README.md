# 🚀 DevSecOps CI/CD Pipeline

> **Complete implementation of GitLab CI/CD and GitHub Actions CI/CD pipelines with integrated security scanning, code quality analysis, and Kubernetes deployment.**

[![GitLab CI/CD](https://img.shields.io/badge/GitLab-CI%2FCD-orange?style=for-the-badge&logo=gitlab)](./docs/gitlab-cicd.md)
[![GitHub Actions](https://img.shields.io/badge/GitHub-Actions-blue?style=for-the-badge&logo=github)](./docs/github-actions-cicd.md)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Deployment-326CE5?style=for-the-badge&logo=kubernetes)](https://kubernetes.io/)


## 🎯 Project Overview

This repository demonstrates the implementation of modern DevSecOps practices through comprehensive CI/CD pipelines that integrate security scanning, code quality analysis, and automated deployment workflows.

## 🛠️ Technology Stack

| Category | Tools & Technologies |
|----------|---------------------|
| **🔨 Build Automation** | Maven |
| **🛡️ Security Scanning** | Trivy |
| **📊 Code Quality** | SonarQube |
| **🐳 Containerization** | Docker |
| **☸️ Orchestration** | Kubernetes (KIND) |
| **🏃‍♂️ Execution Environment** | Self-hosted Runners |

## 🏗️ Architecture

The pipeline architecture implements a complete DevSecOps workflow:

![Project Architecture](./docs/images/project_architecture.png)

### Pipeline Flow:
1. **Source Code** → Version control trigger
2. **Build & Test** → Maven compilation and unit testing
3. **Security Scan** → Trivy vulnerability assessment
4. **Quality Gate** → SonarQube code analysis
5. **Container Build** → Docker image creation
6. **Deploy** → Kubernetes cluster deployment


## 📖 Implementation Guides

### GitLab CI/CD Pipeline
Complete guide for implementing GitLab-based CI/CD with integrated DevSecOps practices.

[![GitLab Guide](https://img.shields.io/badge/📖_Read_GitLab_Guide-FF6B35?style=for-the-badge)](./docs/gitlab-cicd.md)

![GitLab Pipeline Status](./docs/images/pipeline_status.png)

---

### GitHub Actions CI/CD Pipeline
Comprehensive implementation of GitHub Actions workflow with complete DevSecOps integration.

[![GitHub Guide](https://img.shields.io/badge/📖_Read_GitHub_Guide-2088FF?style=for-the-badge)](./docs/github-actions-cicd.md)

![GitHub Actions Pipeline Status](./docs/images/pipeline-status-final.png)


## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

<div align="center">

**🚀 Happy DevOps-ing! 🚀**

<!-- Made with ❤️ for the DevSecOps community -->

</div>
# Helm Day 2 - Multi-environment support
