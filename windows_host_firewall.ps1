#Remember to create the GPO first if it doesn't already exist
#The New-NetFirewallRule lines are broken into several line for readability. To create a new line shit+enter is used as break command.
$netGPO = Open-NetGPO -PolicyStore "domain.local\name Simplified Common firewall configuration"

$ZONE36_A = "192.168.24/29"              # VLAN ID: 1000
$ZONE35_B = "192.168..0/29"				# VLAN ID: 1000
$ZONE35_C = "192.168.0.8/29"				# VLAN ID: 1000
$ZONE35_D = "192.168.0.24/29"			# VLAN ID: 1000
[...]

#empty the exisisting ruleset
foreach ($rule in (Get-NetFirewallRule -GPOSession $netGPO | ? {$_.DisplayName -notmatch "Nessus"})) { remove-netfirewallrule -displayname $rule.DisplayName -GPOSession $netGPO}

#Inbound rule to allow ICMPv4 from AAA
New-NetFirewallRule -DisplayName "Domain - Allow ICMPv4 from 10.10.10.200/29 ZONE35-A" -LocalAddress @(
$ZONE35_A 
) -RemoteAddress $ZONE35_A -Protocol ICMPv4 -Direction Inbound -IcmpType 8 -Action Allow -GPOSession $netGPO

#Inbound rules for ZONE35-B
New-NetFirewallRule -DisplayName "Domain - Allow incoming for 10.10.10.10/29 ZONE35-B" -LocalAddress $ZONE35_B -RemoteAddress @(
$ZONE35_A,$ZONE35_B,$ZONE35_C,$ZONE35_D 
) -Protocol any -Direction Inbound -LocalPort any  -Action Allow -GPOSession $netGPO 

[...]

# Specific ports
New-NetFirewallRule -DisplayName "Domain - Allow incoming RDP and AD traffic for 10.10.10.10/29 ZONE35-A" -LocalAddress $ZONE35_A -RemoteAddress @($ZONE35_C) -Protocol TCP -Direction Inbound -LocalPort 3389,53,88,135,389,445,446,636,3268,49152-65532  -Action Allow -GPOSession $netGPO
New-NetFirewallRule -DisplayName "Domain - Allow incoming UDP AD Traffic for 10.10.10.10/29 ZONE35-B" -LocalAddress $ZONE35_B -RemoteAddress @($ZONE35_C) -Protocol UDP -Direction Inbound -LocalPort 53,88,123,389 -Action Allow -GPOSession $netGPO

#save rules
Save-NetGPO -GPOSession $netGPO
