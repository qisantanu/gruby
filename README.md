# Gruby

## Pre-requisites

The following software is required to work with the repository.

- docker 19.03.5+
- docker-compose 1.25.4+

---

## Requirements

This project currently works with:

![Ruby version](https://img.shields.io/static/v1?label=Ruby&message=3.0.0&color=red&&style=for-the-badge)
![Rails](https://img.shields.io/static/v1?label=Rails&message=6.1.7.6&color=9C312A&&style=for-the-badge)
![Bundler](https://img.shields.io/static/v1?label=Bundler&message=2.2.3&color=f77b07&&style=for-the-badge)
![Node](https://img.shields.io/static/v1?label=node&message=16.20.2&color=88B860&&style=for-the-badge)
![Golang](https://img.shields.io/static/v1?label=Go&message=1.18.1&color=87Ceeb&style=for-the-badge)

---

## Project Structure

```bash
├── .env.sample             # env variables for docker-compose.yml for local development
├── Dockerfile              # used by docker-compose.yml for local development
├── Dockerfile.prod         # used in all cloud environemnts, used in CI\CD Pipeline
├── docker-compose.test.yml # to be used to run rspec tests
├── docker-compose.yml      # to be used for development on localhost
├── package.json            # comprise of Application version, automation to run off linters, etc
├── portal                  # Gruby RoR source code
├── .github                 # Github Actions configuration directory
```

## To Start the RPC server
```bash
  go_scripts/populate_sample_file
```

---

To build production image run:

```bash
docker build -t gruby-portal:1.0.5-local . \
     --build-arg USER_ID=1000 \
     --build-arg GROUP_ID=1000 \
     --build-arg RUBY_VERSION=3.0.0 \
     --build-arg BUNDLER_VERSION=2.1.4 \
     --build-arg NODE_MAJOR=16 \
     --build-arg YARN_VERSION=1.22.19 \
     --build-arg SECRET_KEY_BASE=2915f76d5cc723c5b4b5db50f537e775604f21e50b15f99c36d81c72d2bf20ed6a15406fad0b10fab07af1633016bad2151f4cb515e14f19057600921beffcd7 \
     -f Dockerfile.prod
```

---

To create and run container:

```bash
docker run -it \
  -e DATABASE_URL=postgresql://postgres:test_db_password@postgres:5432/postgres \
  -e DB_HOST=postgres \
  -e DB_PORT=5432 \
  -e CONTAINER_ROLE=application \
  -e AWS_REGION=ap-south-1 \
  -p 3000:3000 \
  gruby-portal:1.0.5-local
```
