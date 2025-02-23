# Jupyter server configuration
c.ServerApp.allow_root = True
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.token = ''
c.ServerApp.password = ''
c.ServerApp.open_browser = False
c.ServerApp.allow_remote_access = True
c.ServerApp.terminado_settings = {'shell_command': ['/bin/bash']}
c.ServerApp.root_dir = '/app'
c.ServerApp.quit_button = False
c.ServerApp.notebook_dir = '/app'
c.ServerApp.allow_origin = '*'
c.ServerApp.allow_credentials = True