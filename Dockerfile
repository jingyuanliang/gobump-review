ARG GIT_IMAGE=bitnami/git:2.42.0

FROM ${GIT_IMAGE}

COPY --chmod=755 gobump-review.sh /usr/local/bin/gobump-review

ENTRYPOINT ["gobump-review"]
