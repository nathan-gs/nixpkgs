{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.zookeeper;
  
  zookeeperConfig = ''
    dataDir=${cfg.dataDir}
    clientPort=${toString cfg.port}
    ${cfg.extraConf}
    ${cfg.servers}
  '';

  configDir = pkgs.buildEnv {
    name = "zookeeper-conf";
    paths = [
      (pkgs.writeTextDir "zoo.cfg" zookeeperConfig)
      (pkgs.writeTextDir "log4j.properties" cfg.logging)
    ];
  };

in {

  options.services.zookeeper = {
    enable = mkOption {
      description = "Whether to enable Zookeeper.";
      default = false;
      type = types.uniq types.bool;
    };

    port = mkOption {
      description = "Zookeeper Client port.";
      default = 2181;
      type = types.int;
    };

    id = mkOption {
      description = "Zookeeper ID.";
      default = 0;
      type = types.int;
    };
    
    extraConf = mkOption {
      description = "Extra configuration for Zookeeper.";
      type = types.str;
      default = ''
        initLimit=5
        syncLimit=2
        tickTime=2000
      '';
    };

    servers = mkOption {
      description = "All Zookeeper Servers.";
      default = "";
      type = types.str;
      example = ''
        server.0=host0:2888:3888
        server.1=host1:2888:3888
        server.2=host2:2888:3888
      '';
    };

    logging = mkOption {
      description = "Zookeeper logging configuration.";
      default = ''
      zookeeper.root.logger=INFO, CONSOLE
      log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
      log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout
      log4j.appender.CONSOLE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L] - %m%n
      '';
      type = types.str;
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/zookeeper";
      description = ''
        Data directory for Zookeeper
      '';
    };

    extraCmdLineOptions = mkOption {
      description = "Extra command line options for the Zookeeper launcher.";
      default = [ ];
      type = types.listOf types.string;
      example = [ "-Djava.net.preferIPv4Stack=true" "-Dcom.sun.management.jmxremote" "-Dcom.sun.management.jmxremote.local.only=true" ];
    };

  };

  config = mkIf cfg.enable {
    systemd.services.zookeeper = {
      description = "Zookeeper Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-interfaces.target" ];
      environment = { ZOOCFGDIR = configDir; };
      serviceConfig = {
        ExecStart = ''
          ${pkgs.jre}/bin/java -cp "${pkgs.zookeeper}/*:${pkgs.zookeeper}/lib/*:${configDir}" \
            ${toString cfg.extraCmdLineOptions} \
            -Dlog4j.configuration=file:///${configDir}/log4j.properties \
            -Dzookeeper.root.logger=INFO,CONSOLE
            org.apache.zookeeper.server.quorum.QuorumPeerMain \
            ${configDir}/zoo.cfg
        '';
        User = "zookeeper";
        PermissionsStartOnly = true;
      };
      preStart = ''
        mkdir -m 0700 -p ${cfg.dataDir}
        chown zookeeper ${cfg.dataDir}
        echo "${toString cfg.id}" > ${cfg.dataDir}/myid
      '';
    };

    users.extraUsers = singleton {
      name = "zookeeper";
      uid = config.ids.uids.zookeeper;
      description = "Zookeeper daemon user";
      home = cfg.dataDir;
    };
  };
}