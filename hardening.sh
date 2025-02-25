#!/bin/bash

# Initialize variables
SCRIPT_DIR=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")
SCRIPT_APPLY=false
SCRIPT_FORCE=false

# Function to display help
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -a, --apply       Apply hardening changes to this system."
  echo "  -f, --force       Force changes (ignores SSH warnings)."
  echo "  -h, --help        Show this help message and exit."
  exit 0
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--apply)
      SCRIPT_APPLY=true
      shift # Move to the next argument
      ;;
    -f|--force)
      SCRIPT_FORCE=true
      shift # Move to the next argument
      ;;
    -h|--help)
      show_help # Call the help function and exit
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help or -h to see available options."
      exit 1
      ;;
  esac
done

harden_all() {
    cd "$SCRIPT_DIR/modules"
    source 1.1.1.1_disable_cramfs.sh                          # 1.1.1.1 - Ensure cramfs kernel module is not available
    source 1.1.1.2_disable_freevxfs.sh                        # 1.1.1.2 - Ensure freevxfs kernel module is not available
    source 1.1.1.3_disable_hfs.sh                             # 1.1.1.3 - Ensure hfs kernel module is not available
    source 1.1.1.4_disable_hfsplus.sh                         # 1.1.1.4 - Ensure hfsplus kernel module is not available
    source 1.1.1.5_disable_jffs2.sh                           # 1.1.1.5 - Ensure jffs2 kernel module is not available
    source 1.1.1.6_disable_squashfs.sh                        # 1.1.1.6 - Ensure squashfs kernel module is not available
    source 1.1.1.7_disable_udf.sh                             # 1.1.1.7 - Ensure udf kernel module is not available
    source 1.1.1.8_disable_usb_storage.sh                     # 1.1.1.8 - Ensure usb-storage kernel module is not available
    source 1.1.2.1.1_tmp_partition.sh                         # 1.1.2.1.1 - Ensure /tmp is a separate partition
    source 1.1.2.1.2_tmp_novdev.sh                            # 1.1.2.1.2 - Ensure nodev option set on /tmp partition
    source 1.1.2.1.3_tmp_nosuid.sh                            # 1.1.2.1.3 - Ensure nosuid option set on /tmp partition
    source 1.1.2.1.4_tmp_noexec.sh                            # 1.1.2.1.4 - Ensure noexec option set on /tmp partition
    source 1.1.2.2.1_dev_shm_partition.sh                     # 1.1.2.2.1 - Ensure /dev/shm is a separate partition
    source 1.1.2.2.2_dev_shm_novdev.sh                        # 1.1.2.2.2 - Ensure nodev option set on /dev/shm partition
    source 1.1.2.2.3_dev_shm_nosuid.sh                        # 1.1.2.2.3 - Ensure nosuid option set on /dev/shm partition
    source 1.1.2.2.4_dev_shm_noexec.sh                        # 1.1.2.2.4 - Ensure noexec option set on /dev/shm partition
    source 1.1.2.3.1_home_partition.sh                        # 1.1.2.3.1 - Ensure separate partition exists for /home
    source 1.1.2.3.2_home_novdev.sh                           # 1.1.2.3.2 - Ensure nodev option set on /home partition
    source 1.1.2.3.3_home_nosuid.sh                           # 1.1.2.3.3 - Ensure nosuid option set on /home partition
    source 1.1.2.4.1_var_partition.sh                         # 1.1.2.4.1 - Ensure separate partition exists for /var
    source 1.1.2.4.2_var_novdev.sh                            # 1.1.2.4.2 - Ensure nodev option set on /var partition
    source 1.1.2.4.3_var_nosuid.sh                            # 1.1.2.4.3 - Ensure nosuid option set on /var partition
    source 1.1.2.5.1_var_tmp_partition.sh                     # 1.1.2.5.1 - Ensure separate partition exists for /var/tmp
    source 1.1.2.5.2_var_tmp_novdev.sh                        # 1.1.2.5.2 - Ensure nodev option set on /var/tmp partition
    source 1.1.2.5.3_var_tmp_nosuid.sh                        # 1.1.2.5.3 - Ensure nosuid option set on /var/tmp partition
    source 1.1.2.5.4_var_tmp_noexec.sh                        # 1.1.2.5.4 - Ensure noexec option set on /var/tmp partition
    source 1.1.2.6.1_var_log_partition.sh                     # 1.1.2.6.1 - Ensure separate partition exists for /var/log
    source 1.1.2.6.2_var_log_novdev.sh                        # 1.1.2.6.2 - Ensure nodev option set on /var/log partition
    source 1.1.2.6.3_var_log_nosuid.sh                        # 1.1.2.6.3 - Ensure nosuid option set on /var/log partition
    source 1.1.2.6.4_var_log_noexec.sh                        # 1.1.2.6.4 - Ensure noexec option set on /var/log partition
    source 1.1.2.7.1_var_log_audit_partition.sh               # 1.1.2.7.1 - Ensure separate partition exists for /var/log/audit
    source 1.1.2.7.2_var_log_audit_novdev.sh                  # 1.1.2.7.2 - Ensure nodev option set on /var/log/audit partition
    source 1.1.2.7.3_var_log_audit_nosuid.sh                  # 1.1.2.7.3 - Ensure nosuid option set on /var/log/audit partition
    source 1.1.2.7.4_var_log_audit_noexec.sh                  # 1.1.2.7.4 - Ensure noexec option set on /var/log/audit partition
    source 1.2.1.1_configure_gpg_keys.sh                      # 1.2.1.1 - Ensure GPG keys are configured
    source 1.2.1.2_configure_repositories.sh                  # 1.2.1.2 - Ensure package manager repositories are configured
    source 1.2.2.1_install_updates.sh                         # 1.2.2.1 - Ensure updates, patches, and additional security software are installed
    source 1.4.1_bootloader_password.sh                       # 1.4.1 - Ensure bootloader password is set
    source 1.4.2_bootloader_ownership.sh                      # 1.4.2 - Ensure access to bootloader config is configured
    source 1.5.1_enable_randomized_vm_placement.sh            # 1.5.1 - Ensure address space layout randomization (ASLR) is enabled
    source 1.5.2_disable_ptrace_scope.sh                      # 1.5.2 - Ensure ptrace_scope is restricted
    source 1.5.3_restrict_core_dumps.sh                       # 1.5.3 - Ensure core dumps are restricted
    source 1.5.4_disable_prelink.sh                           # 1.5.4 - Ensure prelink is not installed
    source 1.6.1_remove_os_info_motd.sh                       # 1.6.1 - Ensure message of the day is configured properly
    source 1.6.2_remove_os_info_issue.sh                      # 1.6.2 - Ensure local login warning banner is configured properly
    source 1.6.3_remove_os_info_motd_net.sh                   # 1.6.3 - Ensure remote login warning banner is configured properly
    source 1.6.4_motd_perms.sh                                # 1.6.4 - Ensure access to /etc/motd is configured
    source 1.6.5_etc_issue_perms.sh                           # 1.6.5 - Ensure access to /etc/issue is configured
    source 1.6.6_etc_issue_net_perms.sh                       # 1.6.6 - Ensure access to /etc/issue.net is configured
    source 1.7.1_remove_gdm.sh                                # 1.8.1 - Ensure GNOME Display Manager (GDM) is removed
    source 2.1.1_disable_autofs.sh                            # 2.1.1 - Ensure autofs services are not in use
    source 2.1.2_disable_avahi_server.sh                      # 2.1.2 - Ensure avahi daemon services are not in use
    source 2.1.3_disable_dhcp.sh                              # 2.1.3 - Ensure dhcp server services are not in use
    source 2.1.4_disable_dns_server.sh                        # 2.1.4 - Ensure dns server services are not in use
    source 2.1.5_disable_dnsmasq.sh                           # 2.1.5 - Ensure dnsmasq services are not in use
    source 2.1.6_disable_ftp.sh                               # 2.1.6 - Ensure ftp server services are not in use
    source 2.1.7_disable_ldap.sh                              # 2.1.7 - Ensure ldap server services are not in use
    source 2.1.8_disable_imap_pop.sh                          # 2.1.8 - Ensure message access server services are not in use
    source 2.1.9_disable_nfs.sh                               # 2.1.9 - Ensure network file system services are not in use
    source 2.1.10_disable_nis.sh                              # 2.1.10 - Ensure nis server services are not in use
    source 2.1.11_disable_print_server.sh                     # 2.1.11 - Ensure print server services are not in use
    source 2.1.12_disable_rpc.sh                              # 2.1.12 - Ensure rpcbind services are not in use
    source 2.1.13_disable_rsync.sh                            # 2.1.13 - Ensure rsync services are not in use
    source 2.1.14_disable_samba.sh                            # 2.1.14 - Ensure samba file server services are not in use
    source 2.1.15_disable_snmp.sh                             # 2.1.15 - Ensure snmp services are not in use
    source 2.1.16_disable_tftp.sh                             # 2.1.16 - Ensure tftp server services are not in use
    source 2.1.17_disable_web_proxy.sh                        # 2.1.17 - Ensure web proxy server services are not in use
    source 2.1.18_disable_web_server.sh                       # 2.1.18 - Ensure web server services are not in use
    source 2.1.19_disable_xinetd.sh                           # 2.1.19 - Ensure xinetd services are not in use
    source 2.1.20_disable_xwindow_system.sh                   # 2.1.20 - Ensure X window server services are not in use
    source 2.1.21_mta_localhost.sh                            # 2.1.21 - Ensure mail transfer agent is configured for local-only
    source 2.1.22_disable_nonessential_services.sh            # 2.1.22 - Ensure only approved services are listening on a network interface
    source 2.2.1_disable_nis_client.sh                        # 2.2.1 - Ensure NIS Client is not installed
    source 2.2.2_disable_rsh_client.sh                        # 2.2.2 - Ensure rsh client is not installed
    source 2.2.3_disable_talk_client.sh                       # 2.2.3 - Ensure talk client is not installed
    source 2.2.4_disable_telnet_client.sh                     # 2.2.4 - Ensure telnet client is not installed
    source 2.2.5_disable_ldap_client.sh                       # 2.2.5 - Ensure ldap client is not installed
    source 2.2.6_disable_ftp_client.sh                        # 2.2.6 - Ensure ftp client is not installed
    source 2.3.1.1_use_time_sync.sh                           # 2.3.1.1 - Ensure a single time synchronization daemon is in use
    source 2.3.2.1_configure_systemd-timesync.sh              # 2.3.2.1 - Ensure systemd-timesyncd configured with authorized timeserver
    source 2.3.2.2_enable_systemd-timesync.sh                 # 2.3.2.2 - Ensure systemd-timesyncd is enabled and running
    source 2.3.3.1_configure_chrony.sh                        # 2.3.3.1 - Ensure chrony is configured with authorized timeserver
    source 2.3.3.2_chrony_user.sh                             # 2.3.3.2 - Ensure chrony is running as user _chrony
    source 2.3.3.3_enable_chrony.sh                           # 2.3.3.3 - Ensure chrony is enabled and running
    source 2.3.4.1_configure_acl_ntp.sh                       # 2.3.4.1 - Ensure ntp access control is configured (deprecated)
    source 2.3.4.2_configure_ntp.sh                           # 2.3.4.2 - Ensure ntp is configured with authorized timeserver (deprecated)
    source 2.3.4.3_ntp_user.sh                                # 2.3.4.3 - Ensure ntp is running as user ntp (deprecated)
    source 2.3.4.4_enable_ntp.sh                              # 2.3.4.4 - Ensure ntp is enabled and running (deprecated)
    source 2.4.1.1_enable_cron.sh                             # 2.4.1.1 - Ensure cron daemon is enabled and active
    source 2.4.1.2_crontab_perms.sh                           # 2.4.1.2 - Ensure permissions on /etc/crontab are configured
    source 2.4.1.3_crontab_hourly_perms.sh                    # 2.4.1.3 - Ensure permissions on /etc/cron.hourly are configured
    source 2.4.1.4_crontab_daily_perms.sh                     # 2.4.1.4 - Ensure permissions on /etc/cron.daily are configured
    source 2.4.1.5_crontab_weekly_perms.sh                    # 2.4.1.5 - Ensure permissions on /etc/cron.weekly are configured
    source 2.4.1.6_crontab_monthly_perms.sh                   # 2.4.1.6 - Ensure permissions on /etc/cron.monthly are configured
    source 2.4.1.7_cron_d_perms.sh                            # 2.4.1.7 - Ensure permissions on /etc/cron.d are configured
    source 2.4.1.8_cron_users.sh                              # 2.4.1.8 - Ensure crontab is restricted to authorized users
    source 2.4.2.1_at_users.sh                                # 2.4.2.1 - Ensure at is restricted to authorized users
    source 3.1.1_disable_ipv6.sh                              # 3.1.1 - Ensure IPv6 status is identified
    source 3.1.2_disable_wireless.sh                          # 3.1.2 - Ensure wireless interfaces are disabled
    source 3.1.3_disable_bluetooth.sh                         # 3.1.3 - Ensure bluetooth services are not in use
    source 3.2.1_disable_dccp.sh                              # 3.2.1 - Ensure dccp kernel module is not available
    source 3.2.2_disable_tipc.sh                              # 3.2.2 - Ensure tipc kernel module is not available
    source 3.2.3_disable_rds.sh                               # 3.2.3 - Ensure rds kernel module is not available
    source 3.2.4_disable_sctp.sh                              # 3.2.4 - Ensure sctp kernel module is not available
    source 3.3.1_disable_ip_forwarding.sh                     # 3.3.1 - Ensure ip forwarding is disabled
    source 3.3.2_disable_send_redirects.sh                    # 3.3.2 - Ensure packet redirect sending is disabled
    source 3.3.3_ignore_bogus_icmp_responses.sh               # 3.3.3 - Ensure bogus icmp responses are ignored
    source 3.3.4_ignore_broadcast_requests.sh                 # 3.3.4 - Ensure broadcast icmp requests are ignored
    source 3.3.5_disable_icmp_redirects.sh                    # 3.3.5 - Ensure icmp redirects are not accepted
    source 3.3.6_disable_secure_icmp_redirects.sh             # 3.3.6 - Ensure secure icmp redirects are not accepted
    source 3.3.7_enable_reverse_path_filter.sh                # 3.3.7 - Ensure reverse path filtering is enabled
    source 3.3.8_disable_source_routed_packets.sh             # 3.3.8 - Ensure source routed packets are not accepted
    source 3.3.9_log_martian_packets.sh                       # 3.3.9 - Ensure suspicious packets are logged
    source 3.3.10_enable_tcp_syn_cookies.sh                   # 3.3.10 - Ensure tcp syn cookies is enabled
    source 3.3.11_disable_ipv6_router_advertisement.sh        # 3.3.11 - Ensure ipv6 router advertisements are not accepted
    source 4.1.1_install_ufw.sh                               # 4.1.1 - Ensure ufw is installed
    source 4.1.2_disable_iptables_persistent_ufw.sh           # 4.1.2 - Ensure iptables-persistent is not installed with ufw
    source 4.1.3_enable_ufw.sh                                # 4.1.3 - Ensure ufw service is enabled
    source 4.1.4_ufw_configure_loopback.sh                    # 4.1.4 - Ensure ufw loopback traffic is configured
    source 4.1.5_ufw_configure_outbound.sh                    # 4.1.5 - Ensure ufw outbound connections are configured
    source 4.1.6_ufw_configure_port_rules.sh                  # 4.1.6 - Ensure ufw firewall rules exist for all open ports
    source 4.1.7_ufw_configure_default_deny.sh                # 4.1.7 - Ensure ufw default deny firewall policy
    source 5.1.1_sshd_conf_perms.sh                           # 5.1.1 - Ensure permissions on /etc/ssh/sshd_config are configured
    source 5.1.2_private_host_keys_perms.sh                   # 5.1.2 - Ensure permissions on SSH private host key files are configured
    source 5.1.3_public_host_keys_perms.sh                    # 5.1.3 - Ensure permissions on SSH public host key files are configured
    source 5.1.4_configure_ssh_acess.sh                       # 5.1.4 - Ensure sshd access is configured
    source 5.1.5_sshd_banner.sh                               # 5.1.5 - Ensure sshd Banner is configured
    source 5.1.6_sshd_ciphers.sh                              # 5.1.6 - Ensure sshd Ciphers are configured
    source 5.1.7_sshd_sshd_idle_timeout.sh                    # 5.1.7 - Ensure sshd ClientAliveInterval and ClientAliveCountMax are configured
    source 5.1.8_sshd_disable_forwarding.sh                   # 5.1.8 - Ensure sshd DisableForwarding is enabled
    source 5.1.9_sshd_disable_gssapi_auth.sh                  # 5.1.9 - Ensure sshd GSSAPIAuthentication is disabled
    source 5.1.10_sshd_disable_hostbased_auth.sh              # 5.1.10 - Ensure sshd HostbasedAuthentication is disabled
    source 5.1.11_sshd_enable_ignore_rhosts.sh                # 5.1.11 - Ensure sshd IgnoreRhosts is enabled
    source 5.1.12_sshd_cry_kex.sh                             # 5.1.12 - Ensure sshd KexAlgorithms is configured
    source 5.1.13_sshd_login_grace_time.sh                    # 5.1.13 - Ensure sshd LoginGraceTime is configured
    source 5.1.14_sshd_loglevel.sh                            # 5.1.14 - Ensure sshd LogLevel is configured
    source 5.1.15_sshd_cry_macs.sh                            # 5.1.15 - Ensure sshd MACs are configured
    source 5.1.16_sshd_max_auth_tries.sh                      # 5.1.16 - Ensure sshd MaxAuthTries is configured
    source 5.1.17_sshd_max_sessions.sh                        # 5.1.17 - Ensure sshd MaxSessions is configured
    source 5.1.18_sshd_max_startups.sh                        # 5.1.18 - Ensure sshd MaxStartups is configured
    source 5.1.19_sshd_disable_empty_passwords.sh             # 5.1.19 - Ensure sshd PermitEmptyPasswords is disabled
    source 5.1.20_sshd_disable_root_login.sh                  # 5.1.20 - Ensure sshd PermitRootLogin is disabled
    source 5.1.21_sshd_disable_user_environment.sh            # 5.1.21 - Ensure sshd PermitUserEnvironment is disabled
    source 5.1.22_sshd_enable_pam.sh                          # 5.1.22 - Ensure sshd UsePAM is enabled
    source 5.2.1_install_sudo.sh                              # 5.2.1 - Ensure sudo is installed
    source 5.2.2_sudo_pty.sh                                  # 5.2.2 - Ensure sudo commands use pty
    source 5.2.3_sudo_logfile.sh                              # 5.2.3 - Ensure sudo log file exists
    source 5.2.4_sudo_password_privilege.sh                   # 5.2.4 - Ensure users must provide password for privilege escalation
    source 5.2.5_sudo_re-authenticate_privilege.sh            # 5.2.5 - Ensure re-authentication for privilege escalation is not disabled globally
    source 5.2.6_sudo_auth_timeout.sh                         # 5.2.6 - Ensure sudo authentication timeout is configured correctly
    source 5.2.7_restrict_su.sh                               # 5.2.7 - Ensure access to the su command is restricted
    source 5.3.1.1_update_pam.sh                              # 5.3.1.1 - Ensure latest version of pam is installed
    source 5.3.1.2_install_pam_modules.sh                     # 5.3.1.2 - Ensure libpam-modules is installed
    source 5.3.1.3_install_pam_pwquality.sh                   # 5.3.1.3 - Ensure libpam-pwquality is installed
    source 5.4.1.1_password_max_days.sh                       # 5.4.1.1 - Ensure password expiration is configured
    source 5.4.1.2_password_min_days.sh                       # 5.4.1.2 - Ensure minimum password age is configured
    source 5.4.1.3_password_warn_age.sh                       # 5.4.1.3 - Ensure password expiration warning days is configured
    source 5.4.1.4_password_encrypt_method.sh                 # 5.4.1.4 - Ensure strong password hashing algorithm is configured
    source 5.4.1.5_password_inactive_lock.sh                  # 5.4.1.5 - Ensure inactive password lock is configured
    source 5.4.1.6_password_last_change_past.sh               # 5.4.1.6 - Ensure all users last password change date is in the past
    source 5.4.2.1_find_0_uid_non_root_user.sh                # 5.4.2.1 - Ensure root is the only UID 0 account
    source 5.4.2.2_find_0_gid_non_root_user.sh                # 5.4.2.2 - Ensure root is the only GID 0 account
    source 5.4.2.3_find_0_gid_non_root_group.sh               # 5.4.2.3 - Ensure group root is the only GID 0 group
    source 5.4.2.4_root_password.sh                           # 5.4.2.4 - Ensure root password is set
    source 5.4.2.5_root_path_integrity.sh                     # 5.4.2.5 - Ensure root path integrity
    source 5.4.2.6_root_umask.sh                              # 5.4.2.6 - Ensure root user umask is configured
    source 5.4.2.7_disable_system_accounts.sh                 # 5.4.2.7 - Ensure system accounts do not have a valid login shell
    source 5.4.2.8_disable_invalid_accounts.sh                # 5.4.2.8 - Ensure accounts without a valid login shell are locked
    source 5.4.3.1_etc_shells_nologin.sh                      # 5.4.3.1 - Ensure nologin is not listed in /etc/shells
    source 5.4.3.2_default_shell_timeout.sh                   # 5.4.3.2 - Ensure default user shell timeout is configured
    source 5.4.3.3_default_umask.sh                           # 5.4.3.3 - Ensure default user umask is configured
    source 6.1.1_install_aide.sh                              # 6.1.1 - Ensure AIDE is installed
    source 6.1.2_periodic_check_aide.sh                       # 6.1.2 - Ensure filesystem integrity is regularly checked
    source 6.2.1.1.1_enable_journald.sh                       # 6.2.1.1.1 - Ensure journald service is enabled and active
    source 6.2.1.1.2_journald_perms.sh                        # 6.2.1.1.2  - Ensure journald log file access is configured
    source 6.2.1.1.3_journald_logrotate.sh                    # 6.2.1.1.3 - Ensure journald log file rotation is configured
    source 6.2.1.1.4_journald_disable_forwarding.sh           # 6.2.1.1.4 - Ensure journald ForwardToSyslog is disabled
    source 6.2.1.1.5_journald_write_persistent.sh             # 6.2.1.1.5 - Ensure journald Storage is configured
    source 6.2.1.1.6_journald_compress.sh                     # 6.2.1.1.6 - Ensure journald Compress is configured
    source 6.2.1.2.1_install_journal_remote.sh                # 6.2.1.2.1 - Ensure systemd-journal-remote is installed
    source 6.2.1.2.2_configure_journal_remote.sh              # 6.2.1.2.2 - Ensure systemd-journal-remote authentication is configured
    source 6.2.1.2.3_enable_journal_upload.sh                 # 6.2.1.2.3 - Ensure systemd-journal-upload is enabled and active
    source 6.2.1.2.4_disable_journal_remote.sh                # 6.2.1.1.4 - Ensure journald ForwardToSyslog is disabled
    source 6.2.1.3.1_install_rsyslog.sh                       # 6.2.1.3.1* - Ensure rsyslog is installed
    source 6.2.1.3.2_enable_rsyslog.sh                        # 6.2.1.3.2* - Ensure rsyslog service is enabled and active
    source 6.2.1.3.3_rsyslog_journald_forwarding.sh           # 6.2.1.3.3* - Ensure journald ForwardToSyslog is configured
    source 6.2.1.3.4_rsyslog_perms.sh                         # 6.2.1.3.4* - Ensure rsyslog log file access is configured
    source 6.2.1.3.5_configure_rsyslog.sh                     # 6.2.1.3.5* - Ensure rsyslog logging is configured
    source 6.2.1.3.6_configure_rsyslog_remote.sh              # 6.2.1.3.6* - Ensure rsyslog is configured to send logs to a remote log host
    source 6.2.1.3.7_disable_rsyslog_server.sh                # 6.2.1.3.7* - Ensure rsyslog is not configured to receive logs from a remote client
    source 6.2.2.1_logfile_perms.sh                           # 6.2.2.1 - Ensure access to all logfiles has been configured
    source 6.3.1.1_install_auditd.sh                          # 6.3.1.1 - Ensure auditd is installed
    source 6.3.1.2_enable_auditd.sh                           # 6.3.1.2 - Ensure auditd service is enabled and active
    source 6.3.1.3_audit_bootloader.sh                        # 6.3.1.3 - Ensure auditing for processes that start prior to auditd is enabled
    source 6.3.1.4_audit_backlog_limit.sh                     # 6.3.1.4 - Ensure audit_backlog_limit is sufficient
    source 6.3.2.1_audit_log_storage.sh                       # 6.3.2.1 - Ensure audit log storage size is configured
    source 6.3.2.2_keep_all_audit_logs.sh                     # 6.3.2.2 - Ensure audit logs are not automatically deleted
    source 6.3.2.3_halt_when_audit_logs_full.sh               # 6.3.2.3 - Ensure system is disabled when audit logs are full
    source 6.3.2.4_warn_when_audit_logs_low_space.sh          # 6.3.2.4 - Ensure system warns when audit logs are low on space
    source 6.3.3.1_record_sudoers_edit.sh                     # 6.3.3.1 - Ensure changes to system administration scope (sudoers) is collected
    source 6.3.3.2_record_user_emulation.sh                   # 6.3.3.2 - Ensure actions as another user are always logged
    source 6.3.3.3_record_sudo_log_edit.sh                    # 6.3.3.3 - Ensure events that modify the sudo log file are collected
    source 6.3.3.4_record_date_time_edit.sh                   # 6.3.3.4 - Ensure events that modify date and time information are collected
    source 6.3.3.5_record_network_edit.sh                     # 6.3.3.5 - Ensure events that modify the system's network environment are collected
    source 6.3.3.6_record_privileged_commands.sh              # 6.3.3.6 - Ensure use of privileged commands are collected
    source 6.3.3.7_record_failed_access_file.sh               # 6.3.3.7 - Ensure unsuccessful file access attempts are collected
    source 6.3.3.8_record_user_group_edit.sh                  # 6.3.3.8 - Ensure events that modify user/group information are collected
    source 6.3.3.9_record_dac_edit.sh                         # 6.3.3.9 - Ensure discretionary access control permission modification events are collected
    source 6.3.3.10_record_successful_mount.sh                # 6.3.3.10 - Ensure successful file system mounts are collected
    source 6.3.3.11_record_session_init.sh                    # 6.3.3.11 - Ensure session initiation information is collected
    source 6.3.3.12_record_login_logout.sh                    # 6.3.3.12 - Ensure login and logout events are collected
    source 6.3.3.13_record_file_deletions.sh                  # 6.3.3.13 - Ensure file deletion events by users are collected
    source 6.3.3.14_record_mac_edit.sh                        # 6.3.3.14 - Ensure events that modify the system's Mandatory Access Controls are collected
    source 6.3.3.15_record_chcon_usage.sh                     # 6.3.3.15 - Ensure successful and unsuccessful attempts to use the chcon command are recorded
    source 6.3.3.16_record_setfacl_usage.sh                   # 6.3.3.16 - Ensure successful and unsuccessful attempts to use the setfacl command are recorded
    source 6.3.3.17_record_chacl_usage.sh                     # 6.3.3.17 - Ensure successful and unsuccessful attempts to use the chacl command are recorded
    source 6.3.3.18_record_usermod_usage.sh                   # 6.3.3.18 - Ensure successful and unsuccessful attempts to use the usermod command are recorded
    source 6.3.3.19_record_kernel_modules.sh                  # 6.3.3.19 - Ensure kernel module loading unloading and modification is collected
    source 6.3.3.20_freeze_auditd_conf.sh                     # 6.3.3.20 - Ensure the audit configuration is immutable
    source 6.3.3.21_load_auditd_conf.sh                       # 6.3.3.21 - Ensure the running and on disk configuration is the same
    source 6.3.4.1_audit_log_perms.sh                         # 6.3.4.1 - Ensure audit log files mode is configured
    source 6.3.4.2_audit_log_user.sh                          # 6.3.4.2 - Ensure only authorized users own audit log files
    source 6.3.4.3_audit_log_group.sh                         # 6.3.4.3 - Ensure only authorized groups are assigned ownership of audit log files
    source 6.3.4.4_audit_log_dir_perms.sh                     # 6.3.4.4 - Ensure the audit log directory mode is configured
    source 6.3.4.5_audit_conf_perms.sh                        # 6.3.4.5 - Ensure audit configuration files mode is configured
    source 6.3.4.6_audit_conf_user.sh                         # 6.3.4.6 - Ensure audit configuration files are owned by root
    source 6.3.4.7_audit_conf_group.sh                        # 6.3.4.7 - Ensure audit configuration files belong to group root
    source 6.3.4.8_audit_tools_perms.sh                       # 6.3.4.8 - Ensure audit tools mode is configured
    source 6.3.4.9_audit_tools_user.sh                        # 6.3.4.9 - Ensure audit tools are owned by root
    source 6.3.4.10_audit_tools_group.sh                      # 6.3.4.10 - Ensure audit tools belong to group root
    source 7.1.1_etc_passwd_perms.sh                          # 7.1.1 - Ensure permissions on /etc/passwd are configured
    source 7.1.2_etc_passwd-_perms.sh                         # 7.1.2 - Ensure permissions on /etc/passwd- are configured
    source 7.1.3_etc_group_perms.sh                           # 7.1.3 - Ensure permissions on /etc/group are configured
    source 7.1.4_etc_group-_perms.sh                          # 7.1.4 - Ensure permissions on /etc/group- are configured
    source 7.1.5_etc_shadow_perms.sh                          # 7.1.5 - Ensure permissions on /etc/shadow are configured
    source 7.1.6_etc_shadow-_perms.sh                         # 7.1.6 - Ensure permissions on /etc/shadow- are configured
    source 7.1.7_etc_gshadow_perms.sh                         # 7.1.7 - Ensure permissions on /etc/gshadow are configured
    source 7.1.8_etc_gshadow-_perms.sh                        # 7.1.8 - Ensure permissions on /etc/gshadow- are configured
    source 7.1.9_etc_shells_perms.sh                          # 7.1.9 - Ensure permissions on /etc/shells are configured
    source 7.1.10_etc_security_opasswd_perms.sh               # 7.1.10 - Ensure permissions on /etc/security/opasswd are configured
    source 7.1.11_find_world_writable_files.sh                # 7.1.11 - Ensure world writable files and directories are secured
    source 7.1.12_find_unowned_files.sh                       # 7.1.12 - Ensure no files or directories without an owner and a group exist
    source 7.1.13_find_suid_sgid_files.sh                     # 7.1.13 - Ensure SUID and SGID files are reviewed
    source 7.2.1_use_etc_shadow.sh                            # 7.2.1 - Ensure accounts in /etc/passwd use shadowed passwords
    source 7.2.2_disable_unsecured_accounts.sh                # 7.2.2 - Ensure /etc/shadow password fields are not empty
    source 7.2.3_etc_passwd_groups.sh                         # 7.2.3 - Ensure all groups in /etc/passwd exist in /etc/group
    source 7.2.4_empty_shadow_group.sh                        # 7.2.4 - Ensure shadow group is empty
    source 7.2.5_check_duplicate_uid.sh                       # 7.2.5 - Ensure no duplicate UIDs exist
    source 7.2.6_check_duplicate_gid.sh                       # 7.2.6 - Ensure no duplicate GIDs exist
    source 7.2.7_check_duplicate_username.sh                  # 7.2.7 - Ensure no duplicate user names exist
    source 7.2.8_check_duplicate_group.sh                     # 7.2.8 - Ensure no duplicate group names exist
    source 7.2.9_check_user_homedir.sh                        # 7.2.9 - Ensure local interactive user home directories are configured
    source 7.2.10_check_user_dotfiles.sh                      # 7.2.10 - Ensure local interactive user dot files access is configured
    source 99.1.1_install_libpam-tmpdir.sh                    # 99.1.1 - Ensure libpam-tmpdir is installed
    source 99.1.2_install_apt-listbugs.sh                     # 99.1.2 - Ensure apt-listbugs is installed
    source 99.1.3_install_needrestart.sh                      # 99.1.3 - Ensure needrestart is installed
    source 99.1.4.1_install_fail2ban.sh                       # 99.1.4.1 - Ensure fail2ban is installed
    source 99.1.4.2_enable_fail2ban.sh                        # 99.1.4.2 - Ensure fail2ban is enabled and running
    source 99.1.5_install_debsums.sh                          # 99.1.5 - Ensure debsums is installed
    source 99.1.6_install_apt-show-versions.sh                # 99.1.6 - Ensure apt-show-versions is installed
    source 99.1.7.1_install_acct.sh                           # 99.1.7.1 - Ensure acct is installed
    source 99.1.7.2_enable_acct.sh                            # 99.1.7.2 - Ensure acct is enabled and running
    source 99.1.8.1_install_sysstat.sh                        # 99.1.8.1 - Ensure sysstat is installed
    source 99.1.8.2_sysstat_log_perms.sh                      # 99.1.8.2 - Ensure sysstat log umask is configured
    source 99.1.8.3_enable_sysstat.sh                         # 99.1.8.3 - Ensure sysstat is enabled and running
    source 99.1.8.4_disable_sysstat_cron.sh                   # 99.1.8.4 - Ensure additional sysstat cron job is disabled
    source 99.1.9.1_install_systemd-resolved.sh               # 99.1.9.1 - Ensure systemd-resolved is installed
    source 99.1.9.2_systemd-resolved_dns.sh                   # 99.1.9.2 - Ensure DNS is configured
    source 99.1.9.3_configure_systemd-resolved.sh             # 99.1.9.3 - Ensure systemd-resolved is configured
    source 99.1.9.4_enable_systemd-resolved.sh                # 99.1.9.4 - Ensure systemd-resolved is enabled and running
    source 99.2.1_sudoers_perms.sh                            # 99.2.1 - Ensure permissions on /etc/sudoers.d are configured
    source 99.3.1_disable_tty_ldisc_autoload.sh               # 99.3.1 - Ensure autoloading of TTY line disciplines is disabled
    source 99.3.2_enable_protected_fifos.sh                   # 99.3.2 - Ensure writing to FIFOs is restricted
    source 99.3.3_enable_core_uses_pid.sh                     # 99.3.3 - Ensure core files have process id as filename suffix
    source 99.3.4_enable_kptr_restrict.sh                     # 99.3.4 - Ensure visibility of kernel pointers is restricted
    source 99.3.5_disable_sysrq.sh                            # 99.3.5 - Ensure magic SysRq key is disabled
    source 99.3.6_disable_unprivileged_bpf.sh                 # 99.3.6 - Ensure bpf() function is restricted
    source 99.3.7_enable_bpf_jit_harden.sh                    # 99.3.7 - Ensure BPF JIT compiler hardening is enabled
    source 99.4.1_sshd_disable_tcp_forwarding.sh              # 99.4.1 - Ensure sshd AllowTcpForwarding is disabled
    source 99.4.2_sshd_disable_compression.sh                 # 99.4.2 - Ensure sshd Compression is disabled
    source 99.4.3_sshd_disable_tcp_keepalive.sh               # 99.4.3 - Ensure sshd TCPKeepAlive is disabled
    source 99.4.4_sshd_disable_agent_forwarding.sh            # 99.3.4 - Ensure sshd AllowAgentForwarding is disabled
    source 99.4.5_sshd_disable_x11_forwarding.sh              # 99.4.5 - Ensure sshd X11Forwarding is disabled
    source 99.5.1_password_hashing_rounds.sh                  # 99.5.1 - Ensure password hashing rounds is configured
    source 99.9.1_disable_modules.sh                          # 99.9.1 - Ensure loading and unloading of kernel modules at runtime is disabled
    source 99.9.2_ufw_disable_sysctl_overrides.sh             # 99.9.2 - Ensure ufw IPT_SYSCTL is disabled
}

harden_all