# Jib Container Image Build Guide

## Overview
This project is configured to use **Google Jib** for building optimized container images without requiring Docker daemon.

## Configuration Details

### Base Image
- **Image**: `eclipse-temurin:21-jre-jammy`
- **Java Version**: 21 (JRE only for smaller image size)
- **Platforms**: Multi-architecture support (amd64, arm64)

### Image Naming
- **Image Name**: `com.example/oltp:0.0.1-SNAPSHOT`
- **Tags**: `latest`

### Container Configuration
- **Exposed Port**: 8080
- **JVM Memory**: 256MB initial, 512MB max (with container-aware settings)
- **Format**: OCI (Open Container Initiative)

## Build Commands

### 1. Build to Docker Daemon (Local)
```bash
./gradlew jibDockerBuild
```
This builds the image and loads it into your local Docker daemon.

### 2. Build to Docker Registry
```bash
./gradlew jib
```
This builds and pushes the image directly to a container registry (requires registry configuration).

### 3. Build to Tar Archive
```bash
./gradlew jibBuildTar
```
This creates a tar archive of the image at `build/jib-image.tar`.

### 4. Custom Image Name
```bash
./gradlew jib --image=myregistry.io/myapp:v1.0.0
```

## Push to Container Registry

### Docker Hub
```bash
./gradlew jib --image=docker.io/yourusername/oltp:0.0.1-SNAPSHOT
```

### Google Container Registry (GCR)
```bash
./gradlew jib --image=gcr.io/your-project-id/oltp:0.0.1-SNAPSHOT
```

### Amazon ECR
```bash
# First authenticate
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Then build and push
./gradlew jib --image=123456789012.dkr.ecr.us-east-1.amazonaws.com/oltp:0.0.1-SNAPSHOT
```

### Azure Container Registry (ACR)
```bash
./gradlew jib --image=myregistry.azurecr.io/oltp:0.0.1-SNAPSHOT
```

## Authentication

### Using Docker Credentials
Jib uses Docker's credential helpers by default. Ensure you're logged in:
```bash
docker login
```

### Using Gradle Properties
Add to `~/.gradle/gradle.properties`:
```properties
jib.to.auth.username=your-username
jib.to.auth.password=your-password
```

### Using Environment Variables
```bash
export JIB_TO_USERNAME=your-username
export JIB_TO_PASSWORD=your-password
./gradlew jib
```

## Running the Container

### Run Locally
```bash
docker run -p 8080:8080 com.example/oltp:0.0.1-SNAPSHOT
```

### Run with Environment Variables
```bash
docker run -p 8080:8080 \
  -e SPRING_PROFILES_ACTIVE=prod \
  -e MANAGEMENT_OTLP_METRICS_EXPORT_URL=http://otel-collector:4318/v1/metrics \
  com.example/oltp:0.0.1-SNAPSHOT
```

### Run with Custom JVM Options
```bash
docker run -p 8080:8080 \
  -e JAVA_TOOL_OPTIONS="-Xmx1g -XX:MaxRAMPercentage=80.0" \
  com.example/oltp:0.0.1-SNAPSHOT
```

## Image Optimization Features

### Layering Strategy
Jib automatically creates optimized layers:
1. **Dependencies Layer**: External libraries (rarely changes)
2. **Resources Layer**: Application resources
3. **Classes Layer**: Application classes (changes frequently)

This layering maximizes Docker cache efficiency.

### Reproducible Builds
- Uses `USE_CURRENT_TIMESTAMP` for creation time
- Ensures consistent builds across environments

### Multi-Architecture Support
- Builds for both AMD64 and ARM64 architectures
- Compatible with Apple Silicon (M1/M2) and traditional x86 systems

## Customization

### Change Base Image
Edit `build.gradle`:
```groovy
jib {
    from {
        image = 'eclipse-temurin:21-jre-alpine'  // Use Alpine for smaller size
    }
}
```

### Add Custom Files
Place files in `src/main/jib/` directory:
```
src/main/jib/
├── app/
│   └── resources/
│       └── custom-config.yaml
```

### Modify JVM Flags
Edit the `jvmFlags` section in `build.gradle`:
```groovy
jib {
    container {
        jvmFlags = [
            '-Xms512m',
            '-Xmx1024m',
            '-XX:+UseG1GC'
        ]
    }
}
```

## Troubleshooting

### Build Fails with "Unauthorized"
- Ensure you're authenticated to the registry
- Check credentials in `~/.docker/config.json`

### Image Size Too Large
- Use Alpine-based base image
- Review dependencies in `build.gradle`
- Check for unnecessary files in `src/main/jib/`

### Platform-Specific Issues
- Ensure base image supports target platform
- Use `--platform` flag with Docker run

## Verification

### Check Image Locally
```bash
docker images | grep oltp
```

### Inspect Image
```bash
docker inspect com.example/oltp:0.0.1-SNAPSHOT
```

### Test Health Endpoint
```bash
curl http://localhost:8080/actuator/health
```

### Test Prometheus Metrics
```bash
curl http://localhost:8080/actuator/prometheus
```

## CI/CD Integration

### GitHub Actions Example
```yaml
- name: Build and Push with Jib
  run: ./gradlew jib --image=ghcr.io/${{ github.repository }}:${{ github.sha }}
  env:
    JIB_TO_USERNAME: ${{ github.actor }}
    JIB_TO_PASSWORD: ${{ secrets.GITHUB_TOKEN }}
```

### GitLab CI Example
```yaml
build-image:
  script:
    - ./gradlew jib --image=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  variables:
    JIB_TO_USERNAME: $CI_REGISTRY_USER
    JIB_TO_PASSWORD: $CI_REGISTRY_PASSWORD
```

## Performance Benefits

✅ **No Docker Daemon Required**: Build images without Docker installed  
✅ **Fast Incremental Builds**: Only rebuilds changed layers  
✅ **Reproducible**: Same inputs = same image digest  
✅ **Optimized Layering**: Maximizes cache efficiency  
✅ **Multi-Platform**: Single command for multi-arch images  

## Additional Resources

- [Jib Documentation](https://github.com/GoogleContainerTools/jib)
- [Jib Gradle Plugin](https://github.com/GoogleContainerTools/jib/tree/master/jib-gradle-plugin)
- [Spring Boot with Jib](https://spring.io/guides/gs/spring-boot-docker/)