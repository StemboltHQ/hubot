# Hubot

This is a version of GitHub's Campfire bot, hubot. He's pretty cool.

## Running Hubot Locally

You can run your hubot by running the following.

    % npm start

You'll see some start up output about where your scripts come from and a
prompt.

    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading adapter shell
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/scripts
    [Sun, 04 Dec 2011 18:41:11 GMT] INFO Loading scripts from /home/tomb/Development/hubot/src/scripts
    Hubot>

Then you can interact with hubot by typing `hubot help`.

    Hubot> hubot help

    Hubot> animate me <query> - The same thing as `image me`, except adds a few
    convert me <expression> to <units> - Convert expression to given units.
    help - Displays all of the help commands that Hubot knows about.
    ...

Checkout the [Hubot docs][hubot-docs] for more information.


## Development

Take a look at the scripts in the `./scripts` folder for examples. Read up on what you can do with hubot in the
[Scripting Guide][hubot-scripting].

## Testing

    npm test

We use the [Mocha][mocha] framework for unit testing.

    npm run test-unit

To help writing our specs we use the [Hubot test helper][hubot-test-helper] and
[CO][co] for async control flow.


[co]: https://www.npmjs.com/package/co
[hubot-docs]: https://hubot.github.com/docs/
[hubot-scripting]: https://github.com/github/hubot/blob/master/docs/scripting.md
[hubot-test-helper]: https://github.com/mtsmfm/hubot-test-helper
[mocha]: http://mochajs.org/
