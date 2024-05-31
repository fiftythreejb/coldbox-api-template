# CF - API

- [CF - API](#cf---api)
  - [Description](#description)
    - [Features](#features)
  - [Tech Stack](#tech-stack)
  - [Dependencies](#dependencies)
  - [Authorization](#authorization)
  - [Resources](#resources)


## Description

This is a ColdFusion REST API built with the Ortus ColdBox HMVC starting with a REST template. This will serve as a path forward to remove dependency on the old iWHA web server.

### Features

- The API uses basic Auth to get a JWT as validation for API calls
- [TestBox](https://testbox.ortusbooks.com/) for Unit & integration
    Testing
- Custom routes for each module
  - apiUrl\\moduleName\\get
  - apiUrl\\moduleName\\delete\\:id
  - \...
- Caching (views, queries, any data)
- Custom logging

## Tech Stack

This is a Docker-ized Lucee ColdFusion API built with the Ortus ColdBox HMVC starting with a REST template.

- [ColdBox Documentation](https://coldbox.ortusbooks.com/)
- [ColdBox Rest Template](https://github.com/coldbox-templates/rest)
- [Details on ColdBox API template](https://aresdev.com/coldbox-api-template-options/)
- [CacheBox](https://cachebox.ortusbooks.com/)
- [CbSecurity](https://coldbox-security.ortusbooks.com/)
- Docker
- Lucee Coldfusion server (can be converted to Adobe with config
    change)
- [CommandBox](https://www.ortussolutions.com/products/commandbox)

## Dependencies

All module dependencies can be managed through Docker configs & CommandBox. <https://www.forgebox.io/> is the repository.

- Docker
- MySQL Database
- [CommandBox](https://www.ortussolutions.com/products/commandbox)
- [Forgebox](https://www.forgebox.io/) Modules
  - [CORS](https://www.forgebox.io/view/cors)
  - [ColdBox](https://www.forgebox.io/view/coldbox)
    - **(built in to CB)**
    - [CbSecurity](https://www.forgebox.io/view/cbsecurity)
    - [CacheBox](https://www.forgebox.io/view/cachebox)
    - LogBox
    - cbsecurity
    - cbvalidation
    - BCrypt
    - mementifier
    - commandbox-cfconfig

## Authorization

Uses basic auth and JWT token

## Resources

- [ColdBox Documentation](https://coldbox.ortusbooks.com/)
- [Details on ColdBox API template](https://www.ortussolutions.com/blog/rest2016-coldbox-rest-template)
- [CommandBox Documentation](https://commandbox.ortusbooks.com/)
- Coldfusion Reference
  - <https://cfdocs.org/testbox>
- [ColdBox Master Class Youtube](https://www.youtube.com/watch?v=tiMj5XI6NiQ&list=PLNE-ZbNnndB8l7KajYD5xARxF8bZvTHDV)
- [ColdBox Ortus Masterclass](https://www.cfcasts.com/series/cb-master-class)
- [ColdBox REST YouTube](https://www.youtube.com/watch?v=UdgRt8HIKD0)
