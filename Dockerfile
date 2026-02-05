FROM registry.access.redhat.com/ubi9/openjdk-21

ARG TZ=America/Sao_Paulo
ARG APP_HOME=/usr/app
ARG APP_FILE=spring-example.jar
ARG USER_ID=1001

ENV TZ=${TZ} \
    APP_HOME=${APP_HOME} \
    APP_FILE=${APP_FILE} \
    HOME=${APP_HOME} \
    SPRING_OUTPUT_ANSI_ENABLED=ALWAYS \
    JAVA_OPTS=""

WORKDIR ${APP_HOME}

# Instala tzdata e fontconfig, configura timezone e limpa cache em uma única camada
USER root
RUN set -eux; \
    microdnf install -y --nodocs tzdata fontconfig && \
    ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo ${TZ} > /etc/timezone && \
    mkdir -p /usr/share/fonts/custom/rawline && \
    microdnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum

# Copia fontes com ownership correto e atualiza cache de fontes
RUN fc-cache -f -v && fc-list | grep -i Rawline || true

EXPOSE 8080

# Muda para usuário não-root
USER ${USER_ID}

# Copia o JAR já construído (espera `target/${APP_FILE}`)
COPY --chown=${USER_ID}:0 target/${APP_FILE} ${APP_HOME}/

# ENTRYPOINT em forma exec via sh -c para expandir JAVA_OPTS e suportar sinais
ENTRYPOINT ["sh","-c","exec java $JAVA_OPTS -jar ${APP_HOME}/${APP_FILE} \"$@\""]



