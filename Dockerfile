FROM python:3.11-slim

# Set working directory in the container
WORKDIR /data

# Install system dependencies (including distutils)
RUN apt-get update && apt-get install -y \
    python3-setuptools \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Django and other Python packages
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files into the container
COPY . .

# Run database migrations (optional: better to run at runtime, not during build)
# RUN python manage.py migrate

# Expose port
EXPOSE 8000

# Start the Django server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]