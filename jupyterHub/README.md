# JupyterHUb
helm inspect values jupyterhub/jupyterhub >  jupyterHub/config.yaml
helm upgrade --cleanup-on-fail --install $RELEASE jupyterhub/jupyterhub --namespace rack01 --version=0.9.0 --values config.yaml