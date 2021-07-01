@ECHO OFF


SET EXE_DIR="C:\Program Files\WhereScape\RED"
SET APP_DIR="C:\Users\Glenn\Files\Wherescape\Applications"
SET APP_NUM="Demo"
SET APP_VER="Deploy"
SET RES_NUM="Res_Demo"
SET RES_VER="Deploy"
SET RED_ARC=64



SET SRC_DSN="Dev"
SET SRC_DBN="Dev"
SET SRC_USR=""
SET SRC_PWD=""
SET SRC_GRP="Releases"
SET SRC_PRJ="001"



SET RED_USR=""
SET TGT_DSN="Test"
SET TGT_DBN="Test"
SET TGT_USR=""
SET TGT_PWD=""
SET LOG_FIL=%APP_DIR%%APP_NUM%_%APP_VER%.log



SET MED_EXE="%EXE_DIR:"=%\med.exe"
SET RED_CLI="%EXE_DIR:"=%\redcli.exe"



IF "%SRC_GRP:"=%" NEQ "" (
   SET EXP_ARG=' --group-name "%SRC_GRP:"=%"'
   SET SRC_MSG='with the contents of Group %SRC_GRP:"=%'
   SET GIT_PRJ=%SRC_GRP%
) ELSE (
   IF  "%SRC_PRJ:"=%" NEQ "" (
      SET EXP_ARG=' --project-name ^"%SRC_PRJ:"=%^"'
      SET SRC_MSG='with the contents of Project %SRC_PRJ:"=%'
      SET GIT_PRJ=%SRC_PRJ%
   ) ELSE (
      SET EXP_ARG=' --deploy-all'
      SET SRC_MSG='with all objects'
      SET GIT_PRJ="ALL"
   )
)



IF  "%SRC_USR:"=%" NEQ "" (
   SET SRC_ARG=' --meta-user-name %SRC_USR% --meta-password "%SRC_PWD:"=%" '
) ELSE (
   SET SRC_ARG=''
)

IF  "%TGT_USR:"=%" NEQ "" (
   SET TGT_ARG=' --meta-user-name %TGT_USR% --meta-password "%TGT_PWD:"=%" '
) ELSE (
   SET TGT_ARG=''
)



ECHO Creating Deployment application %APP_NUM:"=% %APP_VER:"=% %SRC_MSG:'=% from %SRC_DSN:"=% ..
%MED_EXE% --create-deploy-app --meta-dsn %SRC_DSN% --meta-dsn-arch %RED_ARC% --meta-database %SRC_DBN% %SRC_ARG:'=% --output-dir %APP_DIR% --app-number %APP_NUM% --app-version %APP_VER% %EXP_ARG:'=% 



ECHO Creating Restore Point application %RES_NUM:"=% %RES_VER:"=% from %TGT_DSN:"=% ..
%MED_EXE% --create-deploy-app --meta-dsn %TGT_DSN% --meta-dsn-arch %RED_ARC% --meta-database %TGT_DBN% %TGT_ARG:'=% --output-dir %APP_DIR% --app-number %RES_NUM% --app-version %RES_VER% --app-file-name "%APP_DIR:"=%\app_id_%APP_NUM:"=%_%APP_VER:"=%.wst"



ECHO Deploying application %APP_NUM:"=% %APP_VER:"=% into %TGT_DSN:"=% ..
%RED_CLI% deployment deploy --meta-dsn %TGT_DSN% --meta-dsn-arch %RED_ARC% %TGT_ARG:'=% --app-number %APP_NUM% --app-version %APP_VER% --app-directory %APP_DIR% --red-user-name %RED_USR% > %LOG_FIL% 2>&1

ECHO Completed Successfully
