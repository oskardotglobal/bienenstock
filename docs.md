## _module\.args

Additional arguments passed to each module in addition to ones
like ` lib `, ` config `,
and ` pkgs `, ` modulesPath `\.

This option is also available to all submodules\. Submodules do not
inherit args from their parent module, nor do they provide args to
their parent module or sibling submodules\. The sole exception to
this is the argument ` name ` which is provided by
parent modules to a submodule and contains the attribute name
the submodule is bound to, or a unique generated name if it is
not bound to an attribute\.

Some arguments are already passed by default, of which the
following *cannot* be changed with this option:

 - ` lib `: The nixpkgs library\.

 - ` config `: The results of all options after merging the values from all modules together\.

 - ` options `: The options declared in all modules\.

 - ` specialArgs `: The ` specialArgs ` argument passed to ` evalModules `\.

 - All attributes of ` specialArgs `
   
   Whereas option values can generally depend on other option values
   thanks to laziness, this does not apply to ` imports `, which
   must be computed statically before anything else\.
   
   For this reason, callers of the module system can provide ` specialArgs `
   which are available during import resolution\.
   
   For NixOS, ` specialArgs ` includes
   ` modulesPath `, which allows you to import
   extra modules from the nixpkgs package tree without having to
   somehow make the module aware of the location of the
   ` nixpkgs ` or NixOS directories\.
   
   ```
   { modulesPath, ... }: {
     imports = [
       (modulesPath + "/profiles/minimal.nix")
     ];
   }
   ```

For NixOS, the default value for this option includes at least this argument:

 - ` pkgs `: The nixpkgs package set according to
   the ` nixpkgs.pkgs ` option\.



*Type:*
lazy attribute set of raw value

*Declared by:*
 - [\<nixpkgs/lib/modules\.nix>](https://github.com/NixOS/nixpkgs/blob//lib/modules.nix)



## bienenstock



Configuration for bienenstock



*Type:*
submodule



*Default:*
` { } `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## bienenstock\.enablePackages



See documentation of bienenstockLib\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## bienenstock\.hosts



The hosts which can be deployed\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## bienenstock\.hosts\.\<name>\.modules



NixOS modules to load



*Type:*
list of absolute path



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## bienenstock\.hosts\.\<name>\.remoteBuild



Whether to run the build on the target machine\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## bienenstock\.hosts\.\<name>\.system



The host’s system and architecture



*Type:*
string

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## bienenstock\.hosts\.\<name>\.targetBastion



The SSH jump host’s name, if needed\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## bienenstock\.hosts\.\<name>\.targetHost



The host’s IP or FQDN\. Defaults to the host’s name\.



*Type:*
null or string



*Default:*
` null `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## bienenstock\.hosts\.\<name>\.targetPort



The port the SSH daemon is running on\. Defaults to 22\.



*Type:*
signed integer



*Default:*
` 22 `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## bienenstock\.hosts\.\<name>\.targetUser



The user to log in as\. Defaults to root\.



*Type:*
string



*Default:*
` "root" `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## bienenstock\.modules



NixOS modules to load on all hosts



*Type:*
list of absolute path



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## bienenstock\.rootAuthorizedKeys



A list of SSH keys to apply to all hosts



*Type:*
list of string



*Default:*
` [ ] `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## bienenstock\.sshConfig



The resulting SSH config



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## deploy



The underlying deploy-rs configuration\. Defined so that the module system can merge definitions\.



*Type:*
attribute set of anything



*Default:*
` { } `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)



## flake\.bienenstockLib



Define custom library functions (and packages) to pass to all hosts\.  
May be instantiated by calling using an attrset containing a nixpkgs instance ` pkgs `\.

When instantiated, all functions in the ` packages ` attr will be wrapped in ` pkgs.callPackage `\.
This behaviour can be controlled using ` bienenstock.enablePackages `\.

The packages will also be available as ` bienenstockPkgs ` as a module argument\.



*Type:*
attribute set of anything



*Default:*
` { } `

*Declared by:*
 - [/nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options\.nix](file:///nix/store/1dkbx77x0k3pv57q5kxj99948bmslkj3-source/options.nix)


