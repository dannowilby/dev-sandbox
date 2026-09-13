# Use the official Python image from the Docker Hub as the base image.  
FROM python:3.14-slim

# Install OpenMP runtime required by lightgbm (not included in the slim image).
RUN apt-get update \
    && apt-get install -y libgomp1 git vim curl

RUN useradd -ms /bin/bash dev
USER dev

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

WORKDIR /home/dev

# Change ownership of the /app directory to the non-root user 1000.
RUN chown -R dev:dev /home/dev


EXPOSE 8888

CMD ["sh", "-c", "tail -f /dev/null"]