FROM nginx:alpine

# Copy custom Nginx configuration if needed
# COPY nginx.conf /etc/nginx/nginx.conf

# Copy website files to the container
COPY blog/html /usr/share/nginx/html

# Expose port 80
EXPOSE 80