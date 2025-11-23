ARG BUILD_FROM
FROM ${BUILD_FROM}

# Copy addon-specific entrypoint script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# The run.sh script will handle:
# - Reading Home Assistant addon configuration
# - Setting environment variables from config
# - Starting the container services via systemd
CMD ["/run.sh"]
