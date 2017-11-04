% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This file is part of Webtalk <https://github.com/sandogeorge/webtalk>.
% Copyright (c) 2017 Sando George <sando.csc AT gmail.com>
%
% Webtalk is free software: you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation, either version 3 of the License, or (at your option) any later
% version.
%
% Webtalk is distributed in the hope that it will be useful, but WITHOUT ANY
% WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
% A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with
% Webtalk. If not, see <http://www.gnu.org/licenses/>.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- use_module(library(crypto)).

:- object(main).

    :- info([
        version is 1.0,
        author is 'Sando George',
        date is 2017/10/19,
        comment is 'Defines handlers for HTML pages.'
    ]).

    :- public(index/1).
    :- info(index/1, [
        comment is 'Index page (/).',
        argnames is ['_Request']
    ]).
    index(_Request) :-
        dict_create(Data, _, [
            title: 'Home',
            styles: [],
            scripts: [],
            body_classes: ['index']
        ]),
        templating::render_from_base(index, Data, Render),
        format(Render).

    :- public(install/1).
    :- info(install/1, [
        comment is 'Present for initial configuration'
    ]).
    install(_Request) :-
        lists:member(method(Method), _Request),
        ((Method == 'post', handle_install_post(_Request)) ->
            lists:member(path(Base), _Request),
            routing::redirect(root('.'), Base)
        ;
            dict_create(Data, _, [
                title: 'Install Webtalk',
                page_header: 'Install Webtalk',
                styles: [],
                scripts: ['/static/js/install.js'],
                body_classes: ['install']
            ]),
            templating::render_standalone(install, Data, Render),
            format(Render)
        ).

    :- private(handle_install_post/1).
    handle_install_post(_Request) :-
        http_parameters:http_parameters(_Request, [
            admin_username(Username, [atom]),
            admin_email(Email, [atom]),
            admin_password(Password, [atom])
        ]),
        pcre:re_match("^.+[@].+[.].{2,}$", Email),
        crypto:crypto_password_hash(Password, Hash),
        user:get_model(user, User),
        not(User::exec(current, [Username, _, _, _])),
        not(User::exec(current, [_, _, Email, _])),
        User::exec(add, [Username, Hash, Email, administrator]),
        user:get_model(flag, Flag),
        Flag::exec(add, [installed, true]).

:- end_object.