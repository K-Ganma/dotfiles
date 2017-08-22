# .zshrc コンパイル {{{
if [ ! -f $ZDOTDIR/.zshrc.zwc -o $ZDOTDIR/.zshrc -nt ~$ZDOTDIR/.zshrc.zwc ]; then
    zcompile $ZDOTDIR/.zshrc
fi
#}}}

# プラグイン機能管理 {{{
# + プラグインインストール {{{
# プラグイン管理プラグインzplug/zplugのインストール
if [ ! -f $ZPLUG_HOME/init.zsh ]; then
    mkdir -p $ZPLUG_HOME
    git clone https://github.com/zplug/zplug $ZPLUG_HOME
fi
source $ZPLUG_HOME/init.zsh

# プラグインインストール
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug 'zsh-users/zsh-completions'
zplug 'zsh-users/zsh-autosuggestions'
zplug 'supercrabtree/k'
zplug 'zsh-users/zaw'
zplug 'joel-porquet/zsh-dircolors-solarized'
zplug 'zsh-users/zsh-syntax-highlighting', defer:2
if ! zplug check; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# ++ cdrの設定 (zplug load 前に書かないと zaw-cdr がスキップされる) {{{
autoload -Uz is-at-least

if [ ! -d ${XDG_CACHE_HOME:-$HOME/.cache}/shell ]; then
    mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/shell"
fi
if is-at-least 4.3.10; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':chpwd:*' recent-dirs-max 500
    zstyle ":chpwd:*" recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-file "${XDG_CACHE_HOME:-$HOME/.cache}/shell/chpwd-recent-dirs"
    zstyle ':chpwd:*' recent-dirs-pushd true
fi
# ++ }}}

# インストールされたプラグインを読み込み, PATHに追加
zplug load
# + }}}
#
# + プラグイン設定{{{
# ++ zplug/zplug
# ++ zsh-users/zsh-completions
# ++ zsh-users/zsh-autosuggestions
# ++ supercrabtree/k

# ++ zsh-users/zaw {{{
if zplug check 'zsh-users/zaw';then
    bindkey '\C-d' zaw-cdr
    bindkey '\C-g' zaw-git-branches
    bindkey '\C-@' zaw-gitdir

    function zaw-src-gitdir () {
        _dir=$(git rev-parse --show-cdup 2>/dev/null)
        if [ $? -eq 0 ]
        then
            candidates=( $(git ls-files ${_dir} | perl -MFile::Basename -nle \
                '$a{dirname $_}++; END{delete $a{"."}; print for sort keys %a}') )
        fi
        actions=("zaw-src-gitdir-cd")
        act_descriptions=("change directory in git repos")
    }

    function zaw-src-gitdir-cd () {
        BUFFER="cd $1"
        zle accept-line
    }
    zaw-register-src -n gitdir zaw-src-gitdir
fi
# ++ }}}

# ++ joel-porquet/zsh-dircolors-solarized {{{
if zplug check 'joel-porquet/zsh-dircolors-solarized';then
    setupsolarized dircolors.ansi-light
fi
# ++ }}}

# ++ zsh-users/zsh-syntax-highlighting

# + }}}
# }}}

# デフォルト機能設定 {{{
# + 入力 {{{
# ++ キーバインド {{{
# Vim like キーバインド
bindkey -v

# history の検索
bindkey '^P' history-beginning-search-backward
bindkey '^N' history-beginning-search-forward
if is-at-least 4.3.10; then
    bindkey '^R' history-incremental-pattern-search-backward
    bindkey '^S' history-incremental-pattern-search-forward
fi
# ++ }}}

# ^Dでログアウトしない。
setopt ignoreeof

# cd を省略
setopt auto_cd

# cd -[tab]で過去のディレクトリ
setopt auto_pushd

# cd した先のディレクトリをディレクトリスタックに追加する
setopt auto_pushd

# ディレクトリスタックの重複回避
setopt pushd_ignore_dups

# 拡張 glob を有効にする(ワイルドカード強化)
setopt extended_glob

# 単語の一部として扱われる文字のセットを指定
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# 中止しているプロセスと同じ名前のコマンドを実行したとき, それを実行
setopt auto_resume

# 複数のリダイレクトやパイプに対応
setopt multios

# リダイレクトで上書き禁止
unsetopt noclobber

# C-q, C-sを使わない
setopt no_flow_control

# コマンドラインでも # 以降をコメントと見なす
setopt interactive_comments

# カーソル位置は保持したままファイル名一覧を順次その場で表示
setopt always_last_prompt

# 明確なドットの指定なしで.から始まるファイルをマッチ
setopt globdots

# mkdir {1-3} で フォルダ1, 2, 3を作れる
setopt brace_ccl
# + }}}

# + 出力 {{{
autoload -Uz colors && colors

# ++ プロンプト設定 {{{
# 表示毎にPROMPTの変数展開, コマンド置換, 算術演算等の評価をする
setopt prompt_subst

# コマンド実行後は右プロンプトを消す
setopt transient_rprompt

# +++ PROMPT Setting {{{
function left-prompt {
    FIRST='025m%}'      # ユーザ, ホスト名の文字色
    FIRST_B='254m%}'    # ユーザ, ホスト名の背景色
    SECOND='007m%}'     # カレントディレクトリの文字色
    SECOND_B='238m%}'   # カレントディレクトリの背景色

    sharp='\ue0b0'
    FG='%{[38;5;'
    BG='%{[30;48;5;'
    RESET='%{[0m%}'
    USER_AND_HOST="${BG}${FIRST_B}${FG}${FIRST}"
    DIR="${BG}${SECOND_B}${FG}${SECOND}"

    echo "${USER_AND_HOST}%n@%m${BG}${SECOND_B}${FG}${FIRST_B}${sharp} ${DIR}%~${RESET}${FG}${SECOND_B}${sharp} ${RESET}"
}
PROMPT='`left-prompt`'
# +++ }}}
PROMPT2="%{$fg[green]%}%_> %{$reset_color%}"
setopt correct
SPROMPT="%{$fg[red]%}correct: %R -> %r [nyae]? %{$reset_color%}"
# +++ RPROMPT Setting {{{
if is-at-least 4.3.10; then
    # ++++ Use vcs_info {{{
    function branch-mark {
        echo '\ue0a0^ '
    }
    autoload -Uz vcs_info
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' formats "%F{green}%c%u`branch-mark`[%b]%f"
    if is-at-least 4.3.10; then
        zstyle ':vcs_info:git:*' check-for-changes true
        zstyle ':vcs_info:git:*' stagedstr "%F{yellow}"
        zstyle ':vcs_info:git:*' unstagedstr "%F{red}"
        zstyle ':vcs_info:git:*' actionformats '%F{magenta}[%b|%a]%f'
    fi
    precmd() { vcs_info }
    RPROMPT='${vcs_info_msg_0_}'
    # ++++ }}}
else
    # ++++ Don't use vcs_info {{{
    function get-branch-status {
        local res color
        output=`git status --short 2> /dev/null`
        if [ -z "$output" ]; then
            res=':' # status Clean
            color='%{'${fg[green]}'%}'
        elif [[ $output =~ "[\n]?\?\? " ]]; then
            res='?:' # Untracked
            color='%{'${fg[yellow]}'%}'
        elif [[ $output =~ "[\n]? M " ]]; then
            res='M:' # Modified
            color='%{'${fg[red]}'%}'
        else
            res='A:' # Added to commit
            color='%{'${fg[cyan]}'%}'
        fi
        # echo ${color}${res}'%{'${reset_color}'%}'
        echo ${color} # 色だけ返す
    }
    function get-branch-name {
        # gitディレクトリじゃない場合のエラーは捨てます
        echo `git rev-parse --abbrev-ref HEAD 2> /dev/null`
    }
    function branch-status-check {
        local prefix branchname suffix
        # .gitの中だから除外
        if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
            return
        fi
        branchname=`get-branch-name`
        # ブランチ名が無いので除外
        if [[ -z $branchname ]]; then
            return
        fi
        prefix=`get-branch-status` #色だけ返ってくる
        suffix='%{'${reset_color}'%}'
        echo ${prefix}'\ue0a0'${branchname}${suffix}
    }
    RPROMPT=$'`branch-status-check`'
    # ++++ }}}
fi
# +++ }}}
# ++}}}

# 日本語ファイル名を表示可能にする
setopt print_eight_bit

# バックグラウンドジョブが終了したらすぐに知らせる
setopt notify

# ビープを鳴らさない
setopt no_beep

# 出力の文字列末尾に改行コードが無い場合でも表示
unsetopt promptcr

# 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt long_list_jobs

# ファイル名の展開で辞書順ではなく数値的にソート
setopt numeric_glob_sort

# ファイル名の展開でディレクトリにマッチした場合末尾に / を付加
setopt mark_dirs

# globの警告抑制
setopt nonomatch

# 3秒以上かかったら自動的に消費時間の統計情報を表示する
#REPORTTIME=3
# + }}}

# + 履歴 {{{
# 余分な空白は詰めて記録
setopt hist_reduce_blanks  

# 重複を記録しない
setopt hist_ignore_dups

# 衝突した場合の古いほうを削除
setopt hist_ignore_all_dups

# スペースで始まる場合, 履歴を残さない
setopt hist_ignore_space

# historyコマンドは履歴に登録しない
setopt hist_no_store

# ヒストリを呼び出してから実行する間に一旦編集
setopt hist_verify

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 時刻を記録
setopt extended_history
# + }}}

# + 補完 {{{
# 補完候補が複数あるとき一覧表示
setopt auto_list

# tabで補完候補を切り替える
setopt auto_menu

# 補完候補を詰めて表示
setopt list_packed

# 補完候補一覧でファイルの種別をマーク表示
setopt list_types

# --prefix=/usr などの = 以降も補完
setopt magic_equal_subst

# 変数名, 括弧の対応を補完する
setopt auto_param_keys

# ディレクトリ名の最後に自動的に/を追加
setopt auto_param_slash

# aliasを展開して補完
setopt complete_aliases

# 補完候補リストの日本語を正しく表示
setopt print_eight_bit

# 語の途中でもカーソル位置で補完
setopt complete_in_word

# 続きがある場合, まだ決定しない
setopt rec_exact

# 補完するかの質問は画面を超える時にのみに行う
LISTMAX=0

autoload -Uz compinit && compinit

# 補完侯補をメニューから選択
# select=2: 補完候補を一覧から選択, 補完候補が2つ以上なければすぐに補完
zstyle ':completion:*' menu select=2

# 補完時に, 文字の大小を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 補完候補に着色
if [ -n "$LS_COLORS" ]; then
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

# カレントディレクトリを非表示
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# オブジェクトファイルとか中間ファイルとか非表示
zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#'

# sudo でも補完の対象
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin

# 補完候補をキャッシュ
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/shell/completion-cache-dirs"

# 詳細情報を非表示
zstyle ':completion:*' verbose no

# 補完フォーマット
zstyle ':completion:*:descriptions' format '%BCompleting%b %U%d%u'

# セパレータ
zstyle ':completion:*' list-separator '-->'
# + }}}
# }}}

# その他 {{{
# PATHの重複回避
typeset -U path PATH

# pyenv
eval "$(pyenv init -)"
# }}}


# vim: foldmethod=marker
# vim: foldcolumn=3
# vim: foldlevel=0
