<%@ Page language="C#" explicit="true" %>
<script runat="server">
    public string GetRDPvalue(string eachfile, string valuename)
    {
        string GetRDPvalue = "";
        string fileline = "";

        string theName = "";
        int valuenamelen = 0;
        System.IO.StreamReader contentfile = new System.IO.StreamReader(eachfile);
        valuenamelen = valuename.Length;
        while ((fileline = contentfile.ReadLine()) != null)
        {
            if (fileline.Length >= valuenamelen)
            {
                string filelineleft = fileline.Substring(0, valuenamelen);
                if ((filelineleft.ToLower() == valuename))
                {
                    theName = fileline.Substring(valuenamelen, fileline.Length - valuenamelen);
                }
            }
        }
        contentfile.Close();
        GetRDPvalue = theName.Replace("|", "");
        return GetRDPvalue;
    }

    public string getAuthenticatedUser() {
        HttpCookie authCookie = HttpContext.Current.Request.Cookies[".ASPXAUTH"];
        if(authCookie == null || authCookie.Value == "") return "";
        try {
            // Decrypt may throw an exception if authCookie.Value is total gargbage
            FormsAuthenticationTicket authTicket = FormsAuthentication.Decrypt(authCookie.Value);
            if(authTicket==null) {
                return "";
            }
            return authTicket.Name;
        }
        catch {
            return "";
        }
    }
</script>
<% string authUser = getAuthenticatedUser(); if(authUser=="") { Response.Redirect("auth/login.aspx?ReturnUrl="+Uri.EscapeUriString(HttpContext.Current.Request.Url.AbsolutePath)); } else { %>
<!DOCTYPE html>
<html lang="en" data-bs-theme="light">
    <head>
        <meta charset="UTF-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>RAWeb - Remote Applications</title>
        <link rel="shortcut icon" href="icon.svg" />
        <!-- Latest compiled and minified CSS -->
        <link href="lib/bootstrap.min.css" rel="stylesheet" />

        <!-- Latest compiled JavaScript -->
        <script src="lib/bootstrap.bundle.min.js"></script>

        <!-- Vue 3 -->
        <script src="lib/vue@3.js"></script>

        <style>
            html,
            body,
            #app {
                height: 100%;
            }

            .maindiv {
                background-color: #96f58b;
                padding: 20px;
                border-radius: 10px;
                box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            }

            .apptile {
                border-radius: 5px;
                box-shadow: 0 0 5px rgba(0, 0, 0, 0.2);
                height: 10em;
                width: 10em;
                overflow: hidden;
            }

            .appimg {
                width: 4em;
                height: 4em;
            }

            .apptile-text {
                font-size: 13pt;
                letter-spacing: -0.3px;
                line-height: 17pt;
                text-shadow: 0.02em 0 0 rgb(94 94 94);
            }

            .hostname-text {
                text-overflow: ellipsis;
                white-space: nowrap;
                overflow: hidden;
                font-weight: 500;
                font-size: 10pt;
            }
        </style>
    </head>

    <body>
        <div id="app">
            <header class="py-3 d-flex justify-content-between align-items-center container">
                <div class="d-flex align-items-center gap-2">
                    <img src="icon.svg">
                    <h1>
                        Remote<span style="color: rgb(100, 100, 100)">Apps</span>
                    </h1>
                </div>
                <div class="hostname-text ms-1">{{ webfeed.publisher.name }}</div>
            </header>

            <main class="my-2 container">
                <div class="d-flex flex-column gap-5">
                    <div v-for="subFolder in webfeed.subFolders">
                        <h5 class="mb-4" v-if="subFolder">{{ subFolder.name ? subFolder.name.replace(/^\//, "").replace(/\/$/, "").replace(/\//g, " > ") : "" }}</h5>
                        <div class="d-flex flex-wrap gap-3 justify-content-center justify-content-sm-start">
                            <div class="apptile position-relative d-flex flex-column align-items-center px-1 py-2" v-for="resource in resourcesInFolder(subFolder.name)">
                                <a class="stretched-link" :href="resource.hostingTerminalServers[0].resourceFile.url"></a>
                                <img class="appimg mt-3" :src="'get-image.aspx?image=' + fixSlashes(resource.folders[0].name) + resource.id + '&format=png'" alt="" />
                                <div class="flex-grow-1 d-inline-flex align-items-center pb-1">
                                    <span class="apptile-text text-center">{{ resource.title }}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>

        <script src="feedparser.js"></script>
        <script>
            const vueApp = {
                data() {
                    return {
                        webfeed: {
                            publisher: {
                                name: "Loading...",
                            },
                        },
                    };
                },

                methods: {
                    fetchXML() {
                        return fetch("webfeed.aspx")
                            .then((response) => response.text())
                            .then((xmlString) => (this.webfeed = this.parseWebFeed(xmlString)));
                    },

                    parseWebFeed(xmlString) {
                        return parseFeed(xmlString);
                    },

                    fixSlashes(str) {
                        newStr = str ? str.replace(/^\/+/, "").replace(/\/+$/, "") + "/" : null;
                        return newStr ? newStr : "";
                    },

                    resourcesInFolder(folder) {
                        return this.webfeed.resources.filter((resource) => resource.folders[0].name === folder);
                    }
                },

                mounted() {
                    this.fetchXML();
                },
            };

            app = Vue.createApp(vueApp);
            vm = app.mount("#app");
        </script>
    </body>
</html>
<% } %>
