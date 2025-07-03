# Use Alpine base image
FROM alpine:latest

# Install NGINX
RUN apk add --no-cache nginx

# Copy a basic NGINX config (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Run NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]