module.exports = {
    purge: [
        "../**/*.html.eex",
        "../**/*.html.leex",
        "../**/views/**/*.ex",
        "../**/live/**/*.ex",
        "./js/**/*.js",
    ],
    darkMode: false, // or 'media' or 'class'
    theme: {
        fontFamily: {
          "branding": ["Krona One"],
          "username": ["Special Elite"],
          "nodename": ["Maven Pro"]
        },
        extend: {
            colors: {
                "node-online": 'rgb(5, 150, 105)',
                "node-offline": 'rgb(239, 68, 68)',
            }
        },
    },
    variants: {
        extend: {},
    },
    plugins: [],
};