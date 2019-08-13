# CompleteShell: To Sub-subcommands and Beyond

One limitation of complete-shell is that users can specify completions only to the subcommand level. This is itself is very useful and handles most commands very well. However, some important commands have deeper structures, to the sub-subcommand level:

    docker container prune
    git remote rename
	
for example. The command, subcommand, and even the sub-sub may have separate options, and the arguments must be dealt with in the correct context. The kudzu of creeping featurism may continue to grow and lead, at least temporarily, to further depth.

## Objectives for the mod

The contribution described here is an attempt at a general solution to the subcommand limitation. The goals were

* No modification to the compdef DSL
* Minimal modification to the compiler
* Complete backward compatibility for existing compdefs
* Transparent installation with existing `compdef install`
* A natural generalization of the system, rather than kludging in one more level of subcommands

Ideally, the user would never know the capability existed until she needed it, and then it would just work.

## A \<command>.comp.d/ solution

To gain these features with minimal overall changes, we introduce the concept of "auxiliary compdefs", that are associated with a command's main compdef. These are stored in `$COMPLETE_SHELL_PATH/comp/` along with the main compdef in the `<command>.compdef.d/` directory.

The auxiliary compdefs specify completion for _sub_commands of the main command, using the regular compdef DSL. Within the _sub_command DSL, the `C` statements are used to define completions for the _subsub_commands. By representing the command structure in the source _directories_, the DSL files remain completely flat and preserve the original DSL spec.

Each subcommand with subsubs is represented by an auxiliary compdef with the following naming convention

    <command>.compdef.d/<subcmd>.<command>.comp
	
For example:

    dobby:complete-docker maj$ ls -R docker.comp*
    docker.comp	

    docker.comp.d:
    builder.docker.comp	node.docker.comp	swarm.docker.comp
    config.docker.comp	plugin.docker.comp	system.docker.comp
    container.docker.comp	secret.docker.comp	trust.docker.comp
    image.docker.comp	service.docker.comp	volume.docker.comp
    network.docker.comp	stack.docker.comp

## Aux compdef syntax

Besides the naming convention, there is only one auxiliary compdef-specific requirement. In the `N` line, the command name is replaced with `<subcmd>.<command>`:

    dobby:complete-docker maj$ head docker.comp.d/container.docker.comp 
    CompleteShell v0.2
    
    N container.docker v18.09.2 ..'Manage containers'
    # ^^^^^^^^^^^^^^^^
    # FIX ME...
    A +'CONTAINER'

    C prune                                      .."Remove all stopped containers"
    C rm                                         .."Remove one or more containers"
    C export                                     .."Export a container's filesystem as a tar archive"
    C stop                                       .."Stop one or more running containers"

Options (top-level `O` lines) could be added here, but are probably best kept in the main compdef. Subsub arguments `C...A` should be defined here.

## Installation

Should just work. For example, installing a WIP docker completion:

    dobby:complete-docker maj$ complete-shell add ./docker.comp
    docker
    system.docker
    plugin.docker
    swarm.docker
    image.docker
    config.docker
    service.docker
    secret.docker
    stack.docker
    builder.docker
    container.docker
    volume.docker
    network.docker
    trust.docker
    node.docker

## Demo

    dobby:complete-docker maj$ docker im<TAB>
    import    — Import the contents from a tarball to create a filesystem image
    image     — Manage images
    images    — List images
    dobby:complete-docker maj$ docker image l<TAB>
    ls — List images
    load — Load an image from a tar archive or STDIN
    dobby:complete-docker maj$ docker image ls --<TAB>
    --help — Help for ls subsub 
    	--fake — Fake for demo 
    dobby:complete-docker maj$ docker image ls --help<RET>

    Usage:	docker image ls [OPTIONS] [REPOSITORY[:TAG]]

    List images

    Aliases:
      ls, images, list

    Options:
      -a, --all             Show all images (default hides intermediate images)
          --digests         Show digests
      -f, --filter filter   Filter output based on conditions provided
          --format string   Pretty-print images using a Go template
          --no-trunc        Don't truncate output
      -q, --quiet           Only show numeric IDs
    dobby:complete-docker maj$
	
## Deets

TBD

