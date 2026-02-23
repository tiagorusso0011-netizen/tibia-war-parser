import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { WarParserController } from './war-parser.controller';
import { WarParserService } from './war-parser.service';

@Module({
  imports: [],
  controllers: [AppController, WarParserController],
  providers: [AppService, WarParserService],
})
export class AppModule {}