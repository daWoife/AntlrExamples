﻿// Template generated code from Antlr4BuildTasks.Template v 3.0
namespace yes1
{
    using Antlr4.Runtime;
    public class Program
    {
        static void Main(string[] args)
        {
            ICharStream str = null;
            if (args.Length == 0)
                str = new AntlrInputStream(System.Console.In);
            else
                str = new AntlrFileStream(args[0]);
            var lexer = new Yes1Lexer(str);
            var tokens = new CommonTokenStream(lexer);
            var parser = new Yes1Parser(tokens);
            var tree = parser.file();
            System.Console.WriteLine("parse completed.");
        }
    }
}
