APÓS FAZER O LOGIN E CLICAR EM ALGUMA OUTRA PÁGINA (OU ATUALZIAR) SOU REDIRECIONADO NOVAMENTE PARA A PÁGINA /LOGIN como se não estivesse logado, e AGORA TEMOS ESTES ERROS NO CONSOLE:

AuthContext.tsx:265 Uncaught Error: useAuth deve ser usado dentro de um AuthProvider
    at useAuth (AuthContext.tsx:265:11)
    at LoginPage (LoginPage.tsx:15:49)
    at renderWithHooks (chunk-W6L2VRDA.js?v=a4184c88:11548:26)
    at mountIndeterminateComponent (chunk-W6L2VRDA.js?v=a4184c88:14926:21)
    at beginWork (chunk-W6L2VRDA.js?v=a4184c88:15914:22)
    at HTMLUnknownElement.callCallback2 (chunk-W6L2VRDA.js?v=a4184c88:3674:22)
    at Object.invokeGuardedCallbackDev (chunk-W6L2VRDA.js?v=a4184c88:3699:24)
    at invokeGuardedCallback (chunk-W6L2VRDA.js?v=a4184c88:3733:39)
    at beginWork$1 (chunk-W6L2VRDA.js?v=a4184c88:19765:15)
    at performUnitOfWork (chunk-W6L2VRDA.js?v=a4184c88:19198:20)
useAuth @ AuthContext.tsx:265
LoginPage @ LoginPage.tsx:15
renderWithHooks @ chunk-W6L2VRDA.js?v=a4184c88:11548
mountIndeterminateComponent @ chunk-W6L2VRDA.js?v=a4184c88:14926
beginWork @ chunk-W6L2VRDA.js?v=a4184c88:15914
callCallback2 @ chunk-W6L2VRDA.js?v=a4184c88:3674
invokeGuardedCallbackDev @ chunk-W6L2VRDA.js?v=a4184c88:3699
invokeGuardedCallback @ chunk-W6L2VRDA.js?v=a4184c88:3733
beginWork$1 @ chunk-W6L2VRDA.js?v=a4184c88:19765
performUnitOfWork @ chunk-W6L2VRDA.js?v=a4184c88:19198
workLoopSync @ chunk-W6L2VRDA.js?v=a4184c88:19137
renderRootSync @ chunk-W6L2VRDA.js?v=a4184c88:19116
performSyncWorkOnRoot @ chunk-W6L2VRDA.js?v=a4184c88:18874
flushSyncCallbacks @ chunk-W6L2VRDA.js?v=a4184c88:9119
flushSync @ chunk-W6L2VRDA.js?v=a4184c88:18959
scheduleRefresh @ chunk-W6L2VRDA.js?v=a4184c88:20004
(anonymous) @ @react-refresh:228
performReactRefresh @ @react-refresh:217
(anonymous) @ @react-refresh:608
setTimeout
(anonymous) @ @react-refresh:598
validateRefreshBoundaryAndEnqueueUpdate @ @react-refresh:648
(anonymous) @ PlayerStatsCard.tsx:114
(anonymous) @ client:34
(anonymous) @ client:218
(anonymous) @ client:193
queueUpdate @ client:193
await in queueUpdate
(anonymous) @ client:642
handleMessage @ client:640
(anonymous) @ client:550
AuthContext.tsx:265 Uncaught Error: useAuth deve ser usado dentro de um AuthProvider
    at useAuth (AuthContext.tsx:265:11)
    at LoginPage (LoginPage.tsx:15:49)
    at renderWithHooks (chunk-W6L2VRDA.js?v=a4184c88:11548:26)
    at mountIndeterminateComponent (chunk-W6L2VRDA.js?v=a4184c88:14926:21)
    at beginWork (chunk-W6L2VRDA.js?v=a4184c88:15914:22)
    at HTMLUnknownElement.callCallback2 (chunk-W6L2VRDA.js?v=a4184c88:3674:22)
    at Object.invokeGuardedCallbackDev (chunk-W6L2VRDA.js?v=a4184c88:3699:24)
    at invokeGuardedCallback (chunk-W6L2VRDA.js?v=a4184c88:3733:39)
    at beginWork$1 (chunk-W6L2VRDA.js?v=a4184c88:19765:15)
    at performUnitOfWork (chunk-W6L2VRDA.js?v=a4184c88:19198:20)
useAuth @ AuthContext.tsx:265
LoginPage @ LoginPage.tsx:15
renderWithHooks @ chunk-W6L2VRDA.js?v=a4184c88:11548
mountIndeterminateComponent @ chunk-W6L2VRDA.js?v=a4184c88:14926
beginWork @ chunk-W6L2VRDA.js?v=a4184c88:15914
callCallback2 @ chunk-W6L2VRDA.js?v=a4184c88:3674
invokeGuardedCallbackDev @ chunk-W6L2VRDA.js?v=a4184c88:3699
invokeGuardedCallback @ chunk-W6L2VRDA.js?v=a4184c88:3733
beginWork$1 @ chunk-W6L2VRDA.js?v=a4184c88:19765
performUnitOfWork @ chunk-W6L2VRDA.js?v=a4184c88:19198
workLoopSync @ chunk-W6L2VRDA.js?v=a4184c88:19137
renderRootSync @ chunk-W6L2VRDA.js?v=a4184c88:19116
recoverFromConcurrentError @ chunk-W6L2VRDA.js?v=a4184c88:18736
performSyncWorkOnRoot @ chunk-W6L2VRDA.js?v=a4184c88:18879
flushSyncCallbacks @ chunk-W6L2VRDA.js?v=a4184c88:9119
flushSync @ chunk-W6L2VRDA.js?v=a4184c88:18959
scheduleRefresh @ chunk-W6L2VRDA.js?v=a4184c88:20004
(anonymous) @ @react-refresh:228
performReactRefresh @ @react-refresh:217
(anonymous) @ @react-refresh:608
setTimeout
(anonymous) @ @react-refresh:598
validateRefreshBoundaryAndEnqueueUpdate @ @react-refresh:648
(anonymous) @ PlayerStatsCard.tsx:114
(anonymous) @ client:34
(anonymous) @ client:218
(anonymous) @ client:193
queueUpdate @ client:193
await in queueUpdate
(anonymous) @ client:642
handleMessage @ client:640
(anonymous) @ client:550
@react-refresh:228 The above error occurred in the <LoginPage> component:

    at LoginPage (http://localhost:8081/src/pages/LoginPage.tsx:33:31)
    at RenderedRoute (http://localhost:8081/node_modules/.vite/deps/react-router-dom.js?v=a4184c88:4088:5)
    at Routes (http://localhost:8081/node_modules/.vite/deps/react-router-dom.js?v=a4184c88:4558:5)
    at Router (http://localhost:8081/node_modules/.vite/deps/react-router-dom.js?v=a4184c88:4501:15)
    at BrowserRouter (http://localhost:8081/node_modules/.vite/deps/react-router-dom.js?v=a4184c88:5247:5)
    at ErrorBoundary (http://localhost:8081/src/components/ErrorBoundary.tsx:289:9)
    at AuthProvider (http://localhost:8081/src/contexts/AuthContext.tsx?t=1760984561328:32:32)
    at Provider (http://localhost:8081/node_modules/.vite/deps/chunk-3RXG37ZK.js?v=a4184c88:38:15)
    at TooltipProvider (http://localhost:8081/node_modules/.vite/deps/@radix-ui_react-tooltip.js?v=a4184c88:63:5)
    at QueryClientProvider (http://localhost:8081/node_modules/.vite/deps/@tanstack_react-query.js?v=a4184c88:2934:3)
    at App
    at PlayerProvider (http://localhost:8081/src/contexts/PlayerContext.tsx:91:34)

React will try to recreate this component tree from scratch using the error boundary you provided, ErrorBoundary.
logCapturedError @ chunk-W6L2VRDA.js?v=a4184c88:14032
callback @ chunk-W6L2VRDA.js?v=a4184c88:14078
callCallback @ chunk-W6L2VRDA.js?v=a4184c88:11248
commitUpdateQueue @ chunk-W6L2VRDA.js?v=a4184c88:11265
commitLayoutEffectOnFiber @ chunk-W6L2VRDA.js?v=a4184c88:17075
commitLayoutMountEffects_complete @ chunk-W6L2VRDA.js?v=a4184c88:17980
commitLayoutEffects_begin @ chunk-W6L2VRDA.js?v=a4184c88:17969
commitLayoutEffects @ chunk-W6L2VRDA.js?v=a4184c88:17920
commitRootImpl @ chunk-W6L2VRDA.js?v=a4184c88:19353
commitRoot @ chunk-W6L2VRDA.js?v=a4184c88:19277
performSyncWorkOnRoot @ chunk-W6L2VRDA.js?v=a4184c88:18895
flushSyncCallbacks @ chunk-W6L2VRDA.js?v=a4184c88:9119
flushSync @ chunk-W6L2VRDA.js?v=a4184c88:18959
scheduleRefresh @ chunk-W6L2VRDA.js?v=a4184c88:20004
(anonymous) @ @react-refresh:228
performReactRefresh @ @react-refresh:217
(anonymous) @ @react-refresh:608
setTimeout
(anonymous) @ @react-refresh:598
validateRefreshBoundaryAndEnqueueUpdate @ @react-refresh:648
(anonymous) @ PlayerStatsCard.tsx:114
(anonymous) @ client:34
(anonymous) @ client:218
(anonymous) @ client:193
queueUpdate @ client:193
await in queueUpdate
(anonymous) @ client:642
handleMessage @ client:640
(anonymous) @ client:550
ErrorBoundary.tsx:40 ❌ Error Boundary capturou um erro:
componentDidCatch @ ErrorBoundary.tsx:40
callback @ chunk-W6L2VRDA.js?v=a4184c88:14084
callCallback @ chunk-W6L2VRDA.js?v=a4184c88:11248
commitUpdateQueue @ chunk-W6L2VRDA.js?v=a4184c88:11265
commitLayoutEffectOnFiber @ chunk-W6L2VRDA.js?v=a4184c88:17075
commitLayoutMountEffects_complete @ chunk-W6L2VRDA.js?v=a4184c88:17980
commitLayoutEffects_begin @ chunk-W6L2VRDA.js?v=a4184c88:17969
commitLayoutEffects @ chunk-W6L2VRDA.js?v=a4184c88:17920
commitRootImpl @ chunk-W6L2VRDA.js?v=a4184c88:19353
commitRoot @ chunk-W6L2VRDA.js?v=a4184c88:19277
performSyncWorkOnRoot @ chunk-W6L2VRDA.js?v=a4184c88:18895
flushSyncCallbacks @ chunk-W6L2VRDA.js?v=a4184c88:9119
flushSync @ chunk-W6L2VRDA.js?v=a4184c88:18959
scheduleRefresh @ chunk-W6L2VRDA.js?v=a4184c88:20004
(anonymous) @ @react-refresh:228
performReactRefresh @ @react-refresh:217
(anonymous) @ @react-refresh:608
setTimeout
(anonymous) @ @react-refresh:598
validateRefreshBoundaryAndEnqueueUpdate @ @react-refresh:648
(anonymous) @ PlayerStatsCard.tsx:114
(anonymous) @ client:34
(anonymous) @ client:218
(anonymous) @ client:193
queueUpdate @ client:193
await in queueUpdate
(anonymous) @ client:642
handleMessage @ client:640
(anonymous) @ client:550
ErrorBoundary.tsx:41    Erro: Error: useAuth deve ser usado dentro de um AuthProvider
    at useAuth (AuthContext.tsx:265:11)
    at LoginPage (LoginPage.tsx:15:49)
    at renderWithHooks (chunk-W6L2VRDA.js?v=a4184c88:11548:26)
    at mountIndeterminateComponent (chunk-W6L2VRDA.js?v=a4184c88:14926:21)
    at beginWork (chunk-W6L2VRDA.js?v=a4184c88:15914:22)
    at beginWork$1 (chunk-W6L2VRDA.js?v=a4184c88:19753:22)
    at performUnitOfWork (chunk-W6L2VRDA.js?v=a4184c88:19198:20)
    at workLoopSync (chunk-W6L2VRDA.js?v=a4184c88:19137:13)
    at renderRootSync (chunk-W6L2VRDA.js?v=a4184c88:19116:15)
    at recoverFromConcurrentError (chunk-W6L2VRDA.js?v=a4184c88:18736:28)
componentDidCatch @ ErrorBoundary.tsx:41
callback @ chunk-W6L2VRDA.js?v=a4184c88:14084
callCallback @ chunk-W6L2VRDA.js?v=a4184c88:11248
commitUpdateQueue @ chunk-W6L2VRDA.js?v=a4184c88:11265
commitLayoutEffectOnFiber @ chunk-W6L2VRDA.js?v=a4184c88:17075
commitLayoutMountEffects_complete @ chunk-W6L2VRDA.js?v=a4184c88:17980
commitLayoutEffects_begin @ chunk-W6L2VRDA.js?v=a4184c88:17969
commitLayoutEffects @ chunk-W6L2VRDA.js?v=a4184c88:17920
commitRootImpl @ chunk-W6L2VRDA.js?v=a4184c88:19353
commitRoot @ chunk-W6L2VRDA.js?v=a4184c88:19277
performSyncWorkOnRoot @ chunk-W6L2VRDA.js?v=a4184c88:18895
flushSyncCallbacks @ chunk-W6L2VRDA.js?v=a4184c88:9119
flushSync @ chunk-W6L2VRDA.js?v=a4184c88:18959
scheduleRefresh @ chunk-W6L2VRDA.js?v=a4184c88:20004
(anonymous) @ @react-refresh:228
performReactRefresh @ @react-refresh:217
(anonymous) @ @react-refresh:608
setTimeout
(anonymous) @ @react-refresh:598
validateRefreshBoundaryAndEnqueueUpdate @ @react-refresh:648
(anonymous) @ PlayerStatsCard.tsx:114
(anonymous) @ client:34
(anonymous) @ client:218
(anonymous) @ client:193
queueUpdate @ client:193
await in queueUpdate
(anonymous) @ client:642
handleMessage @ client:640
(anonymous) @ client:550
ErrorBoundary.tsx:42    Info: {componentStack: '\n    at LoginPage (http://localhost:8081/src/pages…alhost:8081/src/contexts/PlayerContext.tsx:91:34)'}

TEMOS TAMBÉM ESTES ERROS NO DEBUG DA PÁGINA:

Algo Deu Errado
Desculpe, encontramos um erro inesperado. A aplicação será reiniciada.

Detalhes do Erro:

Error: useAuth deve ser usado dentro de um AuthProvider

Stack Trace

    at LoginPage (http://localhost:8081/src/pages/LoginPage.tsx?t=1760984562265:33:31)
    at RenderedRoute (http://localhost:8081/node_modules/.vite/deps/react-router-dom.js?v=a4184c88:4088:5)
    at Routes (http://localhost:8081/node_modules/.vite/deps/react-router-dom.js?v=a4184c88:4558:5)
    at Router (http://localhost:8081/node_modules/.vite/deps/react-router-dom.js?v=a4184c88:4501:15)
    at BrowserRouter (http://localhost:8081/node_modules/.vite/deps/react-router-dom.js?v=a4184c88:5247:5)
    at ErrorBoundary (http://localhost:8081/src/components/ErrorBoundary.tsx:289:9)
    at AuthProvider (http://localhost:8081/src/contexts/AuthContext.tsx?t=1760984561328:32:32)
    at Provider (http://localhost:8081/node_modules/.vite/deps/chunk-3RXG37ZK.js?v=a4184c88:38:15)
    at TooltipProvider (http://localhost:8081/node_modules/.vite/deps/@radix-ui_react-tooltip.js?v=a4184c88:63:5)
    at QueryClientProvider (http://localhost:8081/node_modules/.vite/deps/@tanstack_react-query.js?v=a4184c88:2934:3)
    at App
    at PlayerProvider (http://localhost:8081/src/contexts/PlayerContext.tsx:91:34)