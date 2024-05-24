# Asterisk Docker Image Modified for Microsoft Teams

This repository provides a Dockerfile to build and install Asterisk 21 from source on Debian 12, including custom modifications and necessary prerequisites.

## Description

This Dockerfile sets up an Asterisk server and includes custom modifications to the `res_pjsip_nat.c` file to facilitate integration with Microsoft Teams. The modifications ensure that the Fully Qualified Domain Name (FQDN) is used within SIP:TLS frames, which is required by Microsoft Teams for client identification in direct routing.

## Custom Modifications

### Why the Modifications?

The modifications to `res_pjsip_nat.c` are necessary for using Asterisk as a Gateway to Microsoft Teams. By default, Asterisk provides the IP address instead of the FQDN to Microsoft. Microsoft Teams TLS requires an FQDN instead of an IP address for client identification in direct routing. For now, this needs to be hard-coded without more modifications to the Asterisk code.

### Modified Lines

In the function `static pj_status_t nat_on_tx_message(pjsip_tx_data *tdata)`, the following lines are modified:

1. Replace:
   ```c
   pj_strdup2(tdata->pool, &uri->host, ast_sockaddr_stringify_host(&transport_state->external_signaling_address));
   ```
   with:
   ```c
   pj_strdup2(tdata->pool, &uri->host, "ACTUAL.FQDN.HERE");
   ```

2. Replace:
   ```c
   pj_strdup2(tdata->pool, &via->sent_by.host, ast_sockaddr_stringify_host(&transport_state->external_signaling_address));
   ```
   with:
   ```c
   pj_strdup2(tdata->pool, &via->sent_by.host, "ACTUAL.FQDN.HERE");
   ```

## Important Configuration

You need to change the `ACTUAL.FQDN.HERE` value in the Dockerfile to your actual FQDN:


## Usage

### Building the Docker Image

To build the Docker image, navigate to the directory containing the Dockerfile and run the following command:

```bash
docker build -t asterisk-teams .
```

### Running the Docker Container

After the image is built, you can run a container from the image with the following command:

```bash
docker run -d --name asterisk-teams -p 5060:5060 -p 5061:5061 -p 10000-20000:10000-20000/udp asterisk-teams
```

### Checking the Running Container

Use the following command to check if the container is running:

```bash
docker ps
```

### Viewing Container Logs

Use the following command to view the logs of the running container:

```bash
docker logs asterisk-teams
```

### Accessing the Container

Use the following command to access the running container's shell:

```bash
docker exec -it asterisk-teams bash
```

## Additional Information

This Dockerfile also ensures that the SRTP module (`res_srtp.so`) is loaded by checking and appending the necessary configuration to `/etc/asterisk/modules.conf`.

## Credit

Credit and for more details on Microsoft Teams's end refer to [Nick Bouwhuis's blog post - Asterisk as a Teams Direct Routing SBC](https://nick.bouwhuis.net/posts/2022-01-02-asterisk-as-a-teams-sbc/).

## License

This project is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) license. You can view the full license text [here](./LICENSE).

![CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)
