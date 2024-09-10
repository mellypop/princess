local pink=#ff87df
local white=#ffffff
local blue=#00d7ff
local success=💖
local failure=😭
local italstart=$(echo "\e[3m")
local italend=$(echo "\e[23m")

autoload -Uz vcs_info
setopt PROMPT_SUBST

precmd() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # If we're inside a git repository, prepare to display git info
        local unstaged_count=$(git diff --numstat | wc -l | sed 's/^[[:space:]]*//g')
        local staged_count=$(git diff --cached --numstat | wc -l | sed 's/^[[:space:]]*//g')
        local untracked_count=$(git ls-files --others --exclude-standard | wc -l | sed 's/^[[:space:]]*//g')
        local branch=$(git branch --show-current)

        git_prompt="%B%F{$pink}%K{$pink}%F{black}👑 %F{$white}${branch} "

        if ((staged_count!=0)); then
            git_prompt+="%F{$white}${staged_count}♥ "
        fi

        if ((unstaged_count!=0)); then
            git_prompt+="%F{$white}${unstaged_count}♡ "
        fi

        if ((untracked_count!=0)); then
            git_prompt+="%F{$white}${untracked_count}❣ "
        fi

        git_prompt+="%k"
    else
        git_prompt=""
    fi

    last_stat="%(?.${success}.${failure})"

    # Set up the prompt
    prompt1="%F{$pink}╭──%B%F{$pink}%F{$white}%}%K{${pink}%} $italstart%n$italend %K{${white}}%F{${pink}} %m %f%k%F{${${white}}} %B%F{${white}}→%F{${${blue}}} %b%3~ %f"
    prompt2="%F{$pink}╰──${last_stat}%f"
}

separator() {
    local sep="%F{$pink}"

    local terminal_width=$(tput cols)
    local prompt_len=${#${(%):---- %n---%m-- - %3~ }}
    local git_prompt_skel=""

    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local unstaged_count=$(git diff --numstat | wc -l | sed 's/^[[:space:]]*//g')
        local staged_count=$(git diff --cached --numstat | wc -l | sed 's/^[[:space:]]*//g')
        local untracked_count=$(git ls-files --others --exclude-standard | wc -l | sed 's/^[[:space:]]*//g')

        local current_branch=$(git branch --show-current)

        git_prompt_skel+=" 👑${current_branch} "

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
        sep+="─"
    done

    echo "$sep"
}

PROMPT='${prompt1}%F{#644}$(separator)$git_prompt%f%k%b
${prompt2} '
RPROMPT='%F{#f00}$(if [ $? -ne 0 ]; then echo "󰌑%? "; fi)%f $(date "+%I:%M:%S %p")'
