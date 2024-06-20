# Use the official Haskell image to create a build artifact.
# https://hub.docker.com/_/haskell/
FROM haskell as builder

# Copy local code to the container image.
WORKDIR /app
COPY . .

# Build our code, then build the “haskell-blood-bank” executable.
RUN stack setup 9.0.2
RUN stack build --copy-bins --install-ghc

# Move the "haskell-blood-bank" executable to the working directory.
RUN mv "$(stack path --local-install-root)/bin/haskell-blood-bank" .

# Run the web service on container startup.
CMD ["./haskell-blood-bank"]

EXPOSE 8080