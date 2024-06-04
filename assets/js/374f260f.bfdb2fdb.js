"use strict";(self.webpackChunkstaticdocs_starter=self.webpackChunkstaticdocs_starter||[]).push([[2885],{15680:(e,r,n)=>{n.r(r),n.d(r,{MDXContext:()=>d,MDXProvider:()=>u,mdx:()=>h,useMDXComponents:()=>s,withMDXComponents:()=>p});var t=n(96540);function a(e,r,n){return r in e?Object.defineProperty(e,r,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[r]=n,e}function o(){return o=Object.assign||function(e){for(var r=1;r<arguments.length;r++){var n=arguments[r];for(var t in n)Object.prototype.hasOwnProperty.call(n,t)&&(e[t]=n[t])}return e},o.apply(this,arguments)}function i(e,r){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var t=Object.getOwnPropertySymbols(e);r&&(t=t.filter((function(r){return Object.getOwnPropertyDescriptor(e,r).enumerable}))),n.push.apply(n,t)}return n}function c(e){for(var r=1;r<arguments.length;r++){var n=null!=arguments[r]?arguments[r]:{};r%2?i(Object(n),!0).forEach((function(r){a(e,r,n[r])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):i(Object(n)).forEach((function(r){Object.defineProperty(e,r,Object.getOwnPropertyDescriptor(n,r))}))}return e}function l(e,r){if(null==e)return{};var n,t,a=function(e,r){if(null==e)return{};var n,t,a={},o=Object.keys(e);for(t=0;t<o.length;t++)n=o[t],r.indexOf(n)>=0||(a[n]=e[n]);return a}(e,r);if(Object.getOwnPropertySymbols){var o=Object.getOwnPropertySymbols(e);for(t=0;t<o.length;t++)n=o[t],r.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(a[n]=e[n])}return a}var d=t.createContext({}),p=function(e){return function(r){var n=s(r.components);return t.createElement(e,o({},r,{components:n}))}},s=function(e){var r=t.useContext(d),n=r;return e&&(n="function"==typeof e?e(r):c(c({},r),e)),n},u=function(e){var r=s(e.components);return t.createElement(d.Provider,{value:r},e.children)},m="mdxType",f={inlineCode:"code",wrapper:function(e){var r=e.children;return t.createElement(t.Fragment,{},r)}},g=t.forwardRef((function(e,r){var n=e.components,a=e.mdxType,o=e.originalType,i=e.parentName,d=l(e,["components","mdxType","originalType","parentName"]),p=s(n),u=a,m=p["".concat(i,".").concat(u)]||p[u]||f[u]||o;return n?t.createElement(m,c(c({ref:r},d),{},{components:n})):t.createElement(m,c({ref:r},d))}));function h(e,r){var n=arguments,a=r&&r.mdxType;if("string"==typeof e||a){var o=n.length,i=new Array(o);i[0]=g;var c={};for(var l in r)hasOwnProperty.call(r,l)&&(c[l]=r[l]);c.originalType=e,c[m]="string"==typeof e?e:a,i[1]=c;for(var d=2;d<o;d++)i[d]=n[d];return t.createElement.apply(null,i)}return t.createElement.apply(null,n)}g.displayName="MDXCreateElement"},45762:(e,r,n)=>{n.r(r),n.d(r,{assets:()=>l,contentTitle:()=>i,default:()=>u,frontMatter:()=>o,metadata:()=>c,toc:()=>d});var t=n(58168),a=(n(96540),n(15680));const o={sidebar_position:16},i="W0016 - Deprecated Function",c={unversionedId:"erlang-error-index/w/W0016",id:"erlang-error-index/w/W0016",title:"W0016 - Deprecated Function",description:"Error",source:"@site/docs/erlang-error-index/w/W0016.md",sourceDirName:"erlang-error-index/w",slug:"/erlang-error-index/w/W0016",permalink:"/erlang-language-platform/docs/erlang-error-index/w/W0016",draft:!1,tags:[],version:"current",sidebarPosition:16,frontMatter:{sidebar_position:16},sidebar:"tutorialSidebar",previous:{title:"W0015 - Dependent Header",permalink:"/erlang-language-platform/docs/erlang-error-index/w/W0015"},next:{title:"W0017 - Undefined Function",permalink:"/erlang-language-platform/docs/erlang-error-index/w/W0017"}},l={},d=[{value:"Error",id:"error",level:2},{value:"Explanation",id:"explanation",level:2}],p={toc:d},s="wrapper";function u(e){let{components:r,...n}=e;return(0,a.mdx)(s,(0,t.A)({},p,n,{components:r,mdxType:"MDXLayout"}),(0,a.mdx)("h1",{id:"w0016---deprecated-function"},"W0016 - Deprecated Function"),(0,a.mdx)("h2",{id:"error"},"Error"),(0,a.mdx)("pre",null,(0,a.mdx)("code",{parentName:"pre",className:"language-erlang"},"  main() ->\n    b:not_ok_to_use().\n%%  ^^^^^^^^^^^^^^^^^ \ud83d\udca1 warning: Function 'not_ok_to_use/0' is deprecated.\n")),(0,a.mdx)("h2",{id:"explanation"},"Explanation"),(0,a.mdx)("p",null,"The warning message indicates that the invoked function is ",(0,a.mdx)("em",{parentName:"p"},"deprecated"),", which means it is no longer recommended for use."),(0,a.mdx)("p",null,"To fix the problem you should investigate why the function is deprecated and whether there is an alternative function that can be used instead. You may need to refer to documentation to determine the best course of action."),(0,a.mdx)("p",null,"A function is usually deprecated via ",(0,a.mdx)("a",{parentName:"p",href:"https://www.erlang.org/doc/man/xref#deprecated_function"},"the ",(0,a.mdx)("inlineCode",{parentName:"a"},"-deprecated")," attribute"),". This analysis is very similar to the\n",(0,a.mdx)("inlineCode",{parentName:"p"},"deprecated_function_calls")," analysis performed by the ",(0,a.mdx)("a",{parentName:"p",href:"https://www.erlang.org/doc/man/xref.html"},"XRef")," cross-reference tool."),(0,a.mdx)("p",null,"There is currently no support for the ",(0,a.mdx)("inlineCode",{parentName:"p"},"-ignore_xref")," attribute used by ",(0,a.mdx)("inlineCode",{parentName:"p"},"rebar3")," to silent specific instances of this diagnostic. Instead, the ",(0,a.mdx)("a",{parentName:"p",href:"/erlang-language-platform/docs/erlang-error-index/#ignoring-diagnostics"},"standard ",(0,a.mdx)("inlineCode",{parentName:"a"},"elp:ignore")," mechanism")," should be used."))}u.isMDXComponent=!0}}]);