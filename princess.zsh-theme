local pink=#ff87df
local white=#ffffff
local blue=#00d7ff
local success=💖
local failure=😭
local italstart=\e[3m
local italend=\e[23m

autoload -Uz vcs_info
setopt PROMPT_SUBST

precmd() {
    if git rev-parse --is-inside-git-dir >/dev/null 2>&1; then
        # If we're inside a git repository, prepare to display git info
        local unstaged_count=$(git diff --numstat | wc -l)
        local staged_count=$(git diff --cached --numstat | wc -l)
        local untracked_count=$(git ls-files --others --exclude-standard | wc -l)
        local branch=$(git branch --show-current)

    else
        git_prompt=""
    fi

    last_stat="%(?.${success}.${failure})"

    # Set up the prompt
    prompt1="╭──%B%F{${white}%}%K{${pink}%} %n%K{${white}}%F{${pink}}%m%f%k%F{${${white}}} %B%F{${white}}→%F{${${blue}}} %b%2~ %f"
    prompt2="╰──${last_stat}"
}

separator() {
    local sep=""

	local terminal_width=$(tput cols)
	local prompt_len=${#${(%):---- %n-%m- - %2~ }}
	local git_prompt_skel=""

	if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		local unstaged_count=$(git diff --numstat | wc -l)
		local staged_count=$(git diff --cached --numstat | wc -l)
		local untracked_count=$(git ls-files --others --exclude-standard | wc -l)

		local current_branch=$(git branch --show-current)

		git_prompt_skel+=" ${current_branch} "

		if ((staged_count!=0)); then
			git_prompt_skel+="${staged_count}+ "
		fi

		if ((unstaged_count!=0)); then
			git_prompt_skel+="${unstaged_count}* "
		fi

		if ((untracked_count!=0)); then
			git_prompt_skel+="${untracked_count}! "
		fi
	fi

	local git_prompt_len=${#git_prompt_skel}

	separator_len=$((terminal_width - prompt_len - git_prompt_len))

	for ((i=0; i < separator_len; i++)); do
		sep+="󰍴"
	done

	echo "$sep"
}

# Git status options
ZSH_THEME_GIT_PROMPT_PREFIX="%F{026%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}️"
ZSH_THEME_GIT_PROMPT_DIRTY="❗️"
ZSH_THEME_GIT_PROMPT_CLEAN="✨"

PROMPT='${prompt1}%F{#644}${separator}$git_prompt%f%k
${prompt2} '
RPROMPT='%F{#f00}$(if [ $? -ne 0 ]; then echo "󰌑%? "; fi)%f $(date "+%I:%M:%S %p")'
