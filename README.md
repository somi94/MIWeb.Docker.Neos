# MIWeb.Docker.Neos
Docker image for Neos CMS sites and applications

## Usage
### Prequisites
[Docker](https://www.docker.com/)
[Docker Compose](https://docs.docker.com/compose/)
### Setup
#### 1. Create a project directory
Create a empty directory at a location of your choice. This is the place where your project files will reside.

Example:
```
mkdir ~/Projects/Docker/MyNeosProject
```
#### 2. Create the docker compose file
Create a new file named `docker-compose.yml` inside your project folder.
Here is a example file, edit it to your needs:
```
version: '3.3'
services:
  web:
    image: miweb/neos:4.0
    build: https://github.com/somi94/MIWeb.Docker.Neos.git
    ports:
    - '8050:80' # neos application will be available via port 8050, change it if you like
    links:
    - db:db
    volumes:
      # The app directory is where your neos development files will live. 
      # This includes project configuration, composer files and project specific packages (site package, site specific nodetypes...).
      - ./app:/usr/share/neos-project
      # The app-data directory will link to the neos installation.
      # This isn't necessary and can be omitted (especially in production environments) but is useful to keep an eye on neos core files and thirdparty packages.
      # On top of that it will allow your IDE to locate the neos classes.
      - ./app-data/Neos:/var/www/html 
    environment:
      FLOW_CONTEXT: 'Development'                   # the application context
      NEOS_USER_NAME: 'john'                        # neos username    
      NEOS_USER_PASSWORD: 'john'                    # neos password
      NEOS_USER_FIRSTNAME: 'John'                   # your firstname
      NEOS_USER_LASTNAME: 'Doe'                     # your lastname
      NEOS_SITE_PACKAGE: 'Neos.Demo'                # the site package to use (will be imported automatically)
#     NEOS_SITE_PACKAGE: 'My.New.Site'              # the site package to use (will be created andimported automatically)
#     NEOS_SITE_NAME: 'New Neos Site!'
      BUILD_VERSION: '4.0'                          # the neos base version to use
      MYSQL_USER: root                              # mysql username (has to match user defined for db container)
      MYSQL_PASSWORD: root                          # mysql password (has to match password defined for db container)
      MYSQL_DATABASE: database                      # mysql database (has to match database defined for db container)
  db:
    image: mariadb
    command: ['--character-set-server=utf8mb4', '--collation-server=utf8mb4_unicode_ci']
    restart: always
    volumes:
    - ./app-data/mysql:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_USER: root
      MYSQL_PASSWORD: root
      MYSQL_DATABASE: database
```
#### 3. Run it
Navigate to your project directory and start docker compose.

Example:
```
cd ~/Projects/Docker/MyNeosProject
docker-compose up
```
#### 4. Grab a coffe
Go grab a coffe, beer or whatever helps you to bridge the installation time.
After the containers have been built and started, the start script will trigger the initial neos installation.
As soon as you see this:
```
################################
# app initialized
# starting webserver...
################################
```
The installation is completed.

#### 5. Have a look at the results
Use your webbrowser to navigate to your neos installation: `http://localhost:{your_port}/`

Following my example compose file it would be: `http://localhost:8050/`

You should see the the neos demo page (or whatever page you defined as your site package inside your compose file).

Gratz, you've successfully installed neos!

### Starting development
After finishing setup, you can start development.
Those are the most important file locations:
#### app/
Root of your development environment. Contains composer files and directories for project configuration and project specific packages.
#### app/Configuration
Your projects configuration. In a fresh installation, this directory contains a default Settings.yaml, modify it to your needs.

All context specific settings are stored in a subdirectory, named after the active context.

So in `Development` mode, your database credentials will be stored inside `app/Configuration/Development/Settings.yaml`.

**It is highly recommended that you store all necessary credentials inside the projects context configuration file. If you use version control (like git), you should ensure that the context configuration file (and the docker-compose file) will not get versioned to avoid credentials inside your vcs repository.**

**To do this via git, just add the following lines to your .gitignore file:**
```
/app/Configuration/*/*
/docker-compose.yml
```
## ToDos
List of future features that have not been implemented yet.
* Use nginx and more lightweight base image
* Create site package if none given
* Prune existing site and import a new one as soon as site package changed
* Update as soon as neos version changed
* Utilities to build a production image (without development files)
* Add documentation and autocomplete for neos utils
* Add a temporary "Installing..." or "Maintenance..." page
* Automatically re-link dev files if changed
* Add default gitignore (to ignore context configuration)
